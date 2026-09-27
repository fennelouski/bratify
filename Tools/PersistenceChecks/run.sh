#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
check_dir=$(mktemp -d /tmp/bratify-persistence.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
python3 - "$check_dir" <<'PY'
from pathlib import Path
import sys, subprocess
source=Path('brat/EditDesignViewController.swift').read_text()
start=source.index('extension UIColor {\n    convenience init?(hex: String)')
end=source.index('\nextension EditDesignViewController',start)
Path(sys.argv[1]+'/ColorCoding.swift').write_text('import UIKit\n'+source[start:end])
# Compile the actual pre-release decoder too, excluding unrelated rendering methods.
legacy = subprocess.check_output(['git','show','4ae9a23ae98bcd665d8a9a3d3bde4726dfba1968:brat/Design.swift'], text=True)
legacy = legacy[:legacy.index('    func resolvedTextColor')]
legacy = legacy.replace('struct Design: Codable', 'struct LegacyDesign: Codable', 1) + '}\n'
Path(sys.argv[1]+'/LegacyDesign.swift').write_text(legacy)
PY
sdk=$(xcrun --sdk macosx --show-sdk-path)
xcrun swiftc -swift-version 5 -parse-as-library -target arm64-apple-ios17.0-macabi \
 -sdk "$sdk" -F "$sdk/System/iOSSupport/System/Library/Frameworks" \
 brat/DesignManager.swift brat/Design.swift brat/ImageFilterSettings.swift brat/DesignFilterStateSync.swift \
 brat/DesignUndoHistory.swift brat/DesignUndoHistoryStore.swift \
 brat/UIColor+HexString.swift brat/UIColor+Contrast.swift brat/DesignTextColor.swift \
 "$check_dir/ColorCoding.swift" "$check_dir/LegacyDesign.swift" Tools/PersistenceChecks/main.swift -o "$check_dir/check"
"$check_dir/check" "$check_dir"
