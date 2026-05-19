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
        return 0
    fi

    local app_path
    app_path=$(find "$DERIVED_DATA/Build/Products" \
        -maxdepth 3 -name "*.app" -path "*maccatalyst*" 2>/dev/null | head -1)

    if [[ -z "$app_path" ]]; then
        echo "  SKIP: Mac Catalyst app not found in DerivedData."
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

    # Wait up to 10 s for the process to appear.
    local launched=false
    for i in 1 2 3 4 5 6 7 8 9 10; do
        sleep 1
        if pgrep -xq "$process_name"; then
            launched=true
            break
        fi
    done

    if ! $launched; then
        echo "  ERROR: process '$process_name' never appeared."
        return 0
    fi
    sleep 2  # let window finish drawing

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

    # Helper: capture the app window (or a --macos-size sub-region of it).
    # Mac Catalyst windows can't be resized programmatically; manually size the window
    # to match --macos-size before running the script.
    snap() {
        local filename="$1"
        local bounds
        bounds=$(get_win_bounds)
        if [[ -n "$bounds" ]]; then
            local wx wy ww wh
            IFS=',' read -r wx wy ww wh <<< "$bounds"
            local cap_w=${MACOS_WIDTH:-$ww}
            local cap_h=${MACOS_HEIGHT:-$wh}
            if [[ -n "${MACOS_WIDTH:-}" && ( "$cap_w" -gt "$ww" || "$cap_h" -gt "$wh" ) ]]; then
                echo "  WARNING: requested ${cap_w}×${cap_h} exceeds window ${ww}×${wh} — desktop background may be visible"
            fi
            screencapture -R "$wx,$wy,$cap_w,$cap_h" -x "$out/$filename"
            echo "  Captured $filename (${cap_w}×${cap_h} at $wx,$wy)"
        else
            screencapture -x "$out/$filename"
            echo "  Captured $filename (full-screen fallback — window not detected)"
        fi
    }

    # Navigate back to gallery (handles state restoration from previous session).
    # Cmd+[ is the standard macOS/Mac Catalyst back shortcut; three presses is enough.
    osascript >/dev/null 2>&1 <<APPLESCRIPT || true
tell application "$process_name" to activate
delay 0.5
tell application "System Events"
    tell process "$process_name"
        keystroke "[" using command down
        delay 0.4
        keystroke "[" using command down
        delay 0.4
        keystroke "[" using command down
        delay 0.4
    end tell
end tell
APPLESCRIPT
    sleep 0.5

    # Seed: create 3 demo designs before screenshotting.
    if $SEED; then
        local samples="hello kitty
brat summer
very demure"
        echo "$samples" | while IFS= read -r text; do
            osascript >/dev/null 2>&1 <<APPLESCRIPT || true
tell application "System Events"
    tell process "$process_name"
        -- Click the Add (+) button in the toolbar
        click (first button of toolbar 1 of window 1 whose description is "Add")
        delay 1.5
        -- Type the design text into the focused text view
        keystroke "$text"
        delay 0.5
        -- Cmd+[ to go back to gallery
        keystroke "[" using command down
        delay 1
    end tell
end tell
APPLESCRIPT
        done
        sleep 1
    fi

    # Screenshot 1: gallery view
    osascript >/dev/null 2>&1 -e "tell application \"$process_name\" to activate" || true
    sleep 0.5
    snap "01_gallery.png"

    # Screenshot 2: editor — bring app to front then click the first gallery cell.
    # Toolbar height is ~45pt; first-row cell center is ~80pt below the toolbar top.
    local bounds wx wy
    bounds=$(get_win_bounds)
    if [[ -n "$bounds" ]]; then
        IFS=',' read -r wx wy _ _ <<< "$bounds"
    else
        wx=0; wy=31
    fi
    local cell_x=$(( wx + 80 ))
    local cell_y=$(( wy + 120 ))
    osascript >/dev/null 2>&1 <<APPLESCRIPT || true
tell application "$process_name" to activate
delay 0.8
tell application "System Events"
    tell process "$process_name"
        click at {$cell_x, $cell_y}
    end tell
end tell
APPLESCRIPT
    sleep 1.5
    snap "02_editor.png"

    pkill -x "$process_name" 2>/dev/null || true

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
run_macos  && verify_dimensions "$OUTPUT_DIR/macOS"              1280  800 "macOS"

echo ""
echo "Done. Screenshots saved to: $OUTPUT_DIR/"
open "$OUTPUT_DIR"
