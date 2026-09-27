#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/bratify-editor.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
python3 - "$check_dir" <<'PY'
from pathlib import Path
import sys
out=Path(sys.argv[1]);source=Path('brat/EditDesignViewController.swift').read_text()
a=source.index('extension UIColor {\n    convenience init?(hex: String)');b=source.index('\nextension EditDesignViewController',a)
(out/'ColorCoding.swift').write_text('import UIKit\n'+source[a:b])
a=source.index('    private func encodedEditorContent()');b=source.index('    private func showDesignSaveError',a)
methods=source[a:b].replace('private func','func').replace('DesignManager.shared','manager')
# Only the UI boundary and explicit manager injection are substituted. The save
# decision, actual model encoding and production storage methods run unchanged.
(out/'EditorLogic.swift').write_text('''import Foundation
import UIKit
enum ImageService { static var sharedICloudImagesDirectory: URL? }
final class CheckSettings { var backgroundColorHex = ""; var textColorHex = "" }
final class CheckedEditor {
 let manager: DesignManager
 var currentDesign: Design
 var lastSavedEditorContent: Data?
 var settingsManager = CheckSettings()
 var errors: [String] = []
 var backgroundColor: UIColor { currentDesign.backgroundColor }
 var customTextColor: UIColor { currentDesign.textColor }
 var usesAutomaticTextColor: Bool { currentDesign.usesAutomaticTextColor }
 init(design: Design, manager: DesignManager) throws {
  self.currentDesign = design; self.manager = manager
  lastSavedEditorContent = try encodedEditorContent()
 }
 func showDesignSaveError(_ message: String) { errors.append(message) }
'''+methods+'}\n')
PY
sdk=$(xcrun --sdk macosx --show-sdk-path)
xcrun swiftc -swift-version 5 -parse-as-library -target arm64-apple-ios17.0-macabi \
 -sdk "$sdk" -F "$sdk/System/iOSSupport/System/Library/Frameworks" \
 brat/DesignManager.swift brat/Design.swift brat/ImageFilterSettings.swift brat/DesignFilterStateSync.swift \
 brat/DesignUndoHistory.swift brat/DesignUndoHistoryStore.swift \
 brat/UIColor+HexString.swift brat/UIColor+Contrast.swift brat/DesignTextColor.swift \
 "$check_dir/ColorCoding.swift" "$check_dir/EditorLogic.swift" Tools/EditorChecks/main.swift -o "$check_dir/check"
"$check_dir/check" "$check_dir"
