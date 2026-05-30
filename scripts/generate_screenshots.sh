#!/usr/bin/env bash
# generate_screenshots.sh — capture App Store screenshots for iPhone, iPad, and macOS.
#
# Usage:
#   bash scripts/generate_screenshots.sh                        # all platforms
#   bash scripts/generate_screenshots.sh --platform iphone      # iPhone only
#   bash scripts/generate_screenshots.sh --platform ipad        # iPad only
#   bash scripts/generate_screenshots.sh --platform macos       # macOS only
#   bash scripts/generate_screenshots.sh --no-seed              # skip demo content seeding
#   bash scripts/generate_screenshots.sh --macos-size 1280x800  # capture region in points (resize window manually first)
#
# Output: screenshots/<platform>/*.png, verified against App Store minimum dimensions.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

SCHEME="brat"
PROJECT="brat.xcodeproj"
TEST_ID="bratUITests/ScreenshotTests/testCaptureScreenshots"
OUTPUT_DIR="$REPO_ROOT/screenshots"
DERIVED_DATA="$(mktemp -d)/DerivedData"
SEED=true
PLATFORM="all"   # all | iphone | ipad | ios | macos
MACOS_WIDTH=""   # target macOS window width in points (empty = keep current size)
MACOS_HEIGHT=""  # target macOS window height in points

IPHONE_DEVICE="iPhone 17 Pro Max"
IPAD_DEVICE="iPad Pro 13-inch (M5)"

normalize_platform() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        all)               echo "all" ;;
        mac*|osx)          echo "macos" ;;
        ios)               echo "ios" ;;    # ios = iphone + ipad
        *phone*)           echo "iphone" ;;
        *pad*)             echo "ipad" ;;
        *)                 return 1 ;;
    esac
}

# ---------- parse flags ----------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-seed) SEED=false; shift ;;
        --platform|--p|-p)
            PLATFORM="$(normalize_platform "${2:?--platform requires a value}" \
                || { echo "Unknown platform: '$2'. Use: iphone, ipad, ios, macos, all"; exit 1; })"
            shift 2 ;;
        --macos-size|--mac-size)
            _raw="${2:?--macos-size requires WxH (e.g. 1280x800)}"
            MACOS_WIDTH="${_raw%%x*}"
            MACOS_HEIGHT="${_raw##*x}"
            if [[ -z "$MACOS_WIDTH" || -z "$MACOS_HEIGHT" || "$MACOS_WIDTH" == "$MACOS_HEIGHT" ]]; then
                echo "Invalid --macos-size value: '$raw'. Expected format: WxH (e.g. 1280x800)"; exit 1
            fi
            shift 2 ;;
        *) echo "Unknown flag: $1"; echo "Usage: $0 [--platform iphone|ipad|ios|macos|all] [--no-seed] [--macos-size WxH]"; exit 1 ;;
    esac
done

# ---------- helpers ----------

run_tests() {
    local destination="$1"
    local subdir="$2"
    shift 2
    local extra_settings=("$@")   # optional extra xcodebuild build settings

    local result_bundle="$DERIVED_DATA/${subdir}.xcresult"
    # Remove stale bundle from a prior run so the existence check is reliable.
    rm -rf "$result_bundle"

    local seed_args=()
    if $SEED; then
        seed_args=(TEST_RUNNER_BRATIFY_SEED=1)
    fi

    echo ""
    echo "==> Building & running tests: $subdir"
    set +e
    xcodebuild test \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "$destination" \
        -only-testing:"$TEST_ID" \
        -resultBundlePath "$result_bundle" \
        -derivedDataPath "$DERIVED_DATA" \
        "${seed_args[@]+"${seed_args[@]}"}" \
        "${extra_settings[@]+"${extra_settings[@]}"}" \
        CODE_SIGNING_ALLOWED=NO \
        2>&1 | grep -E "^xcodebuild: error|error:|Test Suite|Executed"
    local xcode_exit=$?
    set -e

    if [[ ! -d "$result_bundle" ]]; then
        echo "  SKIP: xcodebuild failed, no result bundle produced."
        return 0
    fi

    extract_screenshots "$result_bundle" "$OUTPUT_DIR/$subdir"
}

extract_screenshots() {
    local bundle="$1"
    local out="$2"
    mkdir -p "$out"

    # Clear any stale output (xcresulttool refuses to overwrite manifest.json).
    rm -rf "$out"
    mkdir -p "$out"

    echo "  Extracting screenshots from $(basename "$bundle")..."

    xcrun xcresulttool export attachments \
        --path "$bundle" \
        --output-path "$out"

    # Rename UUID-named files to human-readable names from the manifest.
    if [[ -f "$out/manifest.json" ]]; then
        python3 - "$out/manifest.json" "$out" <<'PYEOF'
import json, os, sys
manifest = json.load(open(sys.argv[1]))
out_dir = sys.argv[2]
for test in manifest:
    for att in test.get("attachments", []):
        src = os.path.join(out_dir, att["exportedFileName"])
        dst = os.path.join(out_dir, att["suggestedHumanReadableName"])
        if os.path.exists(src):
            os.rename(src, dst)
PYEOF
    fi

    local count
    count=$(find "$out" -maxdepth 1 -name "*.png" | wc -l | tr -d ' ')
    echo "  Found $count screenshot(s)"
}

verify_dimensions() {
    local dir="$1"
    local min_w="$2"
    local min_h="$3"
    local label="$4"

    echo ""
    echo "--- $label (min ${min_w}×${min_h}) ---"
    local found=0
    for f in "$dir"/*.png; do
        [[ -f "$f" ]] || continue
        found=1
        local w h
        w=$(sips -g pixelWidth  "$f" 2>/dev/null | awk '/pixelWidth/{print $2}')
        h=$(sips -g pixelHeight "$f" 2>/dev/null | awk '/pixelHeight/{print $2}')
        local status="OK"
        if [[ -z "$w" || -z "$h" || "$w" -lt "$min_w" || "$h" -lt "$min_h" ]]; then
            status="WARNING: below minimum"
        fi
        printf "  %-60s %s×%s  [%s]\n" "$(basename "$f")" "$w" "$h" "$status"
    done
    if [[ $found -eq 0 ]]; then
        echo "  (no screenshots found)"
    fi
}

# Detect the Mac's current macOS version for the deployment target override.
MACOS_VERSION="$(sw_vers -productVersion | cut -d. -f1-2)"

# macOS Catalyst: build the app and use screencapture rather than XCUITest,
# because xctest's screen-recording permission is unreliable on macOS.
capture_macos() {
    local out="$OUTPUT_DIR/macOS"
    rm -rf "$out"
    mkdir -p "$out"

    # Target App Store dimensions in pixels (@2x Retina).
    local TARGET_PX_W=2560
    local TARGET_PX_H=1600
    # Window width in logical points (= TARGET_PX_W / 2 on @2x displays).
    local CONTENT_W=1280
    # Mac Catalyst merges UINavigationBar into the NSWindow title bar.
    # TOOLBAR_H confirmed at 52pt on macOS 15 / Mac Catalyst.
    local TOOLBAR_H=52

    # Check Screen Recording permission up front — screencapture fails silently otherwise.
    if ! screencapture -x /tmp/sc_permission_check.png 2>/dev/null; then
        echo ""
        echo "==> macOS: SKIP — screencapture failed."
        echo "    Grant Screen Recording permission to your terminal in:"
        echo "    System Settings > Privacy & Security > Screen Recording"
        rm -f /tmp/sc_permission_check.png
        return 0
    fi
    rm -f /tmp/sc_permission_check.png

    # Pre-seed the app's data store with brat-style designs before launch so the
    # app opens with the right content instead of whatever the user had saved.
    echo ""
    echo "==> Seeding brat designs (Charli XCX fan content + image backgrounds)..."
    python3 "$REPO_ROOT/scripts/seed_macos_designs.py" || echo "  Warning: seed script failed — proceeding with existing designs"

    echo ""
    echo "==> Building for macOS (Mac Catalyst)"
    set +e
    xcodebuild build \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "platform=macOS,variant=Mac Catalyst" \
        -derivedDataPath "$DERIVED_DATA" \
        MACOSX_DEPLOYMENT_TARGET="${MACOS_VERSION}" \
        2>&1 | grep -E "^xcodebuild: error|Build succeeded|FAILED|error:"
    local build_status=${PIPESTATUS[0]}
    set -e

    if [[ $build_status -ne 0 ]]; then
        echo "  SKIP: Mac Catalyst build failed (see errors above)."
        python3 "$REPO_ROOT/scripts/seed_macos_designs.py" --restore 2>/dev/null || true
        return 0
    fi

    local app_path
    app_path=$(find "$DERIVED_DATA/Build/Products" \
        -maxdepth 3 -name "*.app" -path "*maccatalyst*" 2>/dev/null | head -1)

    if [[ -z "$app_path" ]]; then
        echo "  SKIP: Mac Catalyst app not found in DerivedData."
        python3 "$REPO_ROOT/scripts/seed_macos_designs.py" --restore 2>/dev/null || true
        return 0
    fi

    local process_name
    process_name=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable" \
        "$app_path/Contents/Info.plist" 2>/dev/null || basename "$app_path" .app)

    # Strip Gatekeeper quarantine — apps built to temp paths are silently blocked otherwise.
    xattr -dr com.apple.quarantine "$app_path" 2>/dev/null || true

    echo "  Launching $process_name..."
    pkill -x "$process_name" 2>/dev/null || true
    sleep 1
    open "$app_path" || true

    # Wait up to 15 s for the process to appear.
    local launched=false
    for i in $(seq 1 15); do
        sleep 1
        if pgrep -xq "$process_name"; then
            launched=true
            break
        fi
    done

    if ! $launched; then
        echo "  ERROR: process '$process_name' never appeared."
        python3 "$REPO_ROOT/scripts/seed_macos_designs.py" --restore 2>/dev/null || true
        return 0
    fi
    sleep 3  # let window finish drawing and data load from disk

    # Helper: get app window bounds via CoreGraphics (Swift, no extra permissions needed).
    # Prints "x,y,w,h" in screen points, or nothing if no matching window is found.
    get_win_bounds() {
        swift - "$process_name" 2>/dev/null <<'SWIFTEOF' || true
import CoreGraphics
let name = CommandLine.arguments[1].lowercased()
if let wl = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] {
    for w in wl {
        if let owner = w["kCGWindowOwnerName"] as? String,
           (owner.lowercased().contains(name) || name.contains(owner.lowercased())),
           let bounds = w["kCGWindowBounds"] as? [String: Any],
           let width = bounds["Width"] as? Double, width > 200,
           let height = bounds["Height"] as? Double, height > 200 {
            let x = (bounds["X"] as? Double) ?? 0
            let y = (bounds["Y"] as? Double) ?? 0
            print("\(Int(x)),\(Int(y)),\(Int(width)),\(Int(height))")
            break
        }
    }
}
SWIFTEOF
    }

    # Maximize window width and height for the target platform.
    osascript >/dev/null 2>&1 <<APPLESCRIPT || true
tell application "$process_name" to activate
delay 1
tell application "System Events"
    tell process "$process_name"
        set size of window 1 to {$CONTENT_W, 900}
        delay 0.5
    end tell
end tell
APPLESCRIPT
    sleep 0.5

    # Pad a raw screencapture PNG to exactly TARGET_PX_W×TARGET_PX_H using PIL.
    # Frames with lime-green (#8ACE00) bars when the captured content is shorter.
    pad_screenshot() {
        local src="$1" dst="$2"
        python3 - "$src" "$dst" "$TARGET_PX_W" "$TARGET_PX_H" <<'PYEOF'
from PIL import Image
import sys
src, dst, tw, th = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
img = Image.open(src).convert("RGB")
w, h = img.size
if w == tw and h == th:
    img.save(dst, "PNG")
else:
    canvas = Image.new("RGB", (tw, th), (0x8A, 0xCE, 0x00))
    canvas.paste(img, ((tw - w) // 2, (th - h) // 2))
    canvas.save(dst, "PNG")
PYEOF
    }

    # Helper: capture the app content (below toolbar) and pad to App Store dimensions.
    # The editor's colorSwatchScrollView (toolbar icons row) sits inside the safe area,
    # so we skip only the NSWindow title+toolbar chrome (TOOLBAR_H points).
    snap() {
        local filename="$1"
        local bounds
        bounds=$(get_win_bounds)
        local tmp="/tmp/snap_raw_${filename}"
        if [[ -n "$bounds" ]]; then
            local wx wy ww wh
            IFS=',' read -r wx wy ww wh <<< "$bounds"
            local cap_y=$((wy + TOOLBAR_H))
            local cap_h=$((wh - TOOLBAR_H))
            screencapture -R "$wx,$cap_y,$CONTENT_W,$cap_h" -x "$tmp"
            echo "  Captured ${CONTENT_W}×${cap_h}pt content → padding to ${TARGET_PX_W}×${TARGET_PX_H}px"
        else
            screencapture -x "$tmp"
            echo "  Captured full-screen (window not detected) → padding to ${TARGET_PX_W}×${TARGET_PX_H}px"
        fi
        pad_screenshot "$tmp" "$out/$filename"
        rm -f "$tmp"
    }

    # CGEvent-based mouse click helper — reliable for Mac Catalyst UIKit views
    # that don't respond to AppleScript's accessibility click at {x, y}.
    local cg_clicker
    cg_clicker=$(mktemp /tmp/cg_clicker_XXXXXX.swift)
    cat > "$cg_clicker" << 'SWIFTEOF'
import CoreGraphics, Foundation
let x = CGFloat(Double(CommandLine.arguments[1])!),
    y = CGFloat(Double(CommandLine.arguments[2])!),
    pt = CGPoint(x: x, y: y)
CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: pt, mouseButton: .left)!.post(tap: .cghidEventTap)
Thread.sleep(forTimeInterval: 0.05)
CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: pt, mouseButton: .left)!.post(tap: .cghidEventTap)
SWIFTEOF

    cg_click() {
        local x="$1" y="$2"
        swift "$cg_clicker" "$x" "$y" 2>/dev/null || true
    }

    # Helper: click one of the editor's swatch-row tool buttons by logical name.
    # Buttons are in a UIStackView with equalSpacing distribution filling the scroll
    # view width (window_width - 62pt).  Button order (Mac):
    #   [0]=spacer(0pt) [1]=Settings [2]=BgImage [3]=Styles [4]=PrimarySliders
    #   [5]=Controls [6]=AspectRatio [7]=FontPicker [8]=ImportWeb
    # Each button is 30pt wide; scroll view starts at x=50pt from window left edge.
    click_swatch_btn() {
        local btn_name="$1"
        local bounds
        bounds=$(get_win_bounds)
        [[ -z "$bounds" ]] && return
        local wx wy ww
        IFS=',' read -r wx wy ww _ <<< "$bounds"

        # Button y-center: safe_area_top(wy+TOOLBAR_H) + top_margin(8) + half_height(15)
        local btn_y=$(( wy + TOOLBAR_H + 23 ))

        # equalSpacing gap between items: (scrollview_width - 8*30pt) / 8 gaps
        local sw_w=$(( ww - 62 ))
        local gap_x100=$(( (sw_w * 100 - 24000) / 8 ))

        local idx
        case "$btn_name" in
            BgImage)    idx=2 ;;
            Styles)     idx=3 ;;
            Controls)   idx=5 ;;
            FontPicker) idx=7 ;;
            *) echo "  Unknown swatch button: $btn_name"; return ;;
        esac

        # center_x within scroll view:
        #   spacer(0) + (idx-1) buttons * 30pt + idx * gap + half-button(15)
        local prev_w=$(( (idx - 1) * 30 ))
        local center_sv=$(( (prev_w * 100 + idx * gap_x100 + 1500) / 100 ))
        local click_x=$(( wx + 50 + center_sv ))

        cg_click "$click_x" "$btn_y"
    }

    # Navigate back to gallery (handles state restoration from previous session).
    osascript >/dev/null 2>&1 <<APPLESCRIPT || true
tell application "$process_name" to activate
delay 0.5
tell application "System Events"
    tell process "$process_name"
        keystroke "[" using command down
        delay 0.5
        keystroke "[" using command down
        delay 0.5
        keystroke "[" using command down
        delay 0.5
    end tell
end tell
APPLESCRIPT
    sleep 1

    # Screenshot 1: gallery — shows the full design collection.
    osascript >/dev/null 2>&1 -e "tell application \"$process_name\" to activate" || true
    sleep 0.5
    snap "01_gallery.png"

    # Open the first gallery cell.
    # Gallery layout: UICollectionViewFlowLayout, maxColumnWidth=240pt, ~5-6 cols.
    # contentInset set at viewDidLoad (safeAreaInsets=0 at that time) + 20pt = 20pt top.
    # First cell: top at screen.y=29+20=49 (partially under toolbar until y=81).
    # First visible row center at roughly y=150pt screen.
    # Uses CoreGraphics mouse events — AppleScript click at {} does not reach UIKit cells.
    local bounds wx wy
    bounds=$(get_win_bounds)
    if [[ -n "$bounds" ]]; then
        IFS=',' read -r wx wy _ _ <<< "$bounds"
    else
        wx=0; wy=29
    fi
    local cell_x=$(( wx + 200 ))
    local cell_y=$(( wy + 120 ))
    osascript >/dev/null 2>&1 -e "tell application \"$process_name\" to activate" || true
    sleep 0.5
    cg_click "$cell_x" "$cell_y"
    sleep 5  # allow background image to load from disk (async ImageService)

    # Screenshot 2: editor — canvas with image background, no sidebar open.
    snap "02_editor.png"

    # Screenshot 3: editor + Filter Styles panel (left sidebar).
    click_swatch_btn "Styles"
    sleep 3
    snap "03_editor_styles.png"

    # Screenshot 4: editor + Design Controls panel.
    click_swatch_btn "Styles"   # toggle Styles off
    sleep 0.5
    click_swatch_btn "Controls"
    sleep 3
    snap "04_editor_controls.png"

    # Screenshot 5: editor + Font Picker sidebar (right side).
    click_swatch_btn "Controls"   # toggle Controls off
    sleep 0.5
    click_swatch_btn "FontPicker"
    sleep 3
    snap "05_editor_fonts.png"

    pkill -x "$process_name" 2>/dev/null || true
    rm -f "$cg_clicker"

    # Restore the user's original designs so the app is unchanged after screenshotting.
    echo "  Restoring original designs..."
    python3 "$REPO_ROOT/scripts/seed_macos_designs.py" --restore 2>/dev/null || true

    local count
    count=$(find "$out" -maxdepth 1 -name "*.png" | wc -l | tr -d ' ')
    echo "  Found $count screenshot(s)"
}

# ---------- main ----------

echo "Screenshot generation started — platform=${PLATFORM}, seed=${SEED}"
echo "Output: $OUTPUT_DIR"
echo "DerivedData: $DERIVED_DATA"

run_iphone() { [[ "$PLATFORM" == "all" || "$PLATFORM" == "iphone" || "$PLATFORM" == "ios" ]]; }
run_ipad()   { [[ "$PLATFORM" == "all" || "$PLATFORM" == "ipad"   || "$PLATFORM" == "ios" ]]; }
run_macos()  { [[ "$PLATFORM" == "all" || "$PLATFORM" == "macos" ]]; }

run_iphone && run_tests "platform=iOS Simulator,name=${IPHONE_DEVICE}" "iPhone_17_Pro_Max"
run_ipad   && run_tests "platform=iOS Simulator,name=${IPAD_DEVICE}"   "iPad_Pro_13inch_M5"
run_macos  && capture_macos

# ---------- dimension verification ----------

echo ""
echo "===== Dimension check ====="
run_iphone && verify_dimensions "$OUTPUT_DIR/iPhone_17_Pro_Max"  1320 2868 "iPhone 17 Pro Max"
run_ipad   && verify_dimensions "$OUTPUT_DIR/iPad_Pro_13inch_M5" 2064 2752 "iPad Pro 13\" M5"
run_macos  && verify_dimensions "$OUTPUT_DIR/macOS"              2560 1600 "macOS (content-only @2x)"

echo ""
echo "Done. Screenshots saved to: $OUTPUT_DIR/"
open "$OUTPUT_DIR"
