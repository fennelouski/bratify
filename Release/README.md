# Bratify 3.3 (26)

App Store ID 6578442696; registered bundle com.nathanfennel.brat; team EJLR2RPSV2. Build the brat scheme for iOS and Mac Catalyst. The existing iOS/macOS3.3 drafts have no selected build; this document is not upload or submission evidence.

The release branch starts at 4ae9a23ae98bcd665d8a9a3d3bde4726dfba1968. The owner's existing Localizable.xcstrings changes are preserved, including its large formatting diff. The baseline patch is recorded in the workspace release audit.

Settings now uses a native SwiftUI form for behavior, gallery and help, retaining the existing detailed font/theme/canvas pickers and Mac sidebar. Acknowledgments include the pinned dependencies' license texts and corresponding-source URL.

Design storage retains the original designs.json array and existing field meanings. Read failures do not trigger sample replacement. A separate UUID deletion journal prevents this release from restoring known deleted designs when merging stale files. Local storage remains durable before cloud publication. Older clients may retain or display stale copies; actual two-device iCloud behavior still needs verification.

Blank artwork uses an explicit compatibility marker so the previous decoder can read the entire library. New clients restore the exact blank text. An older client can drop the marker on rewriting and retain an invisible character; nonblank text is unchanged. Regression checks compile both current and baseline model decoders.

The editor saves actual typography/filter/canvas/image changes and preserves creation time and identity. Storage failures remain visible and retryable. Imported images are persistent assets and are not evicted as disposable cache entries. Failed imports do not replace the current background. Web imports use user-selected HTTPS websites and no alternate-host retry.

Run these isolated checks:

- Tools/PersistenceChecks/run.sh
- Tools/EditorChecks/run.sh
- python3 Tools/ImageStorageChecks/run.py

They use temporary stores; no real app Documents/iCloud data, image library or account is accessed. Passing checks do not establish native UI, real CloudKit/iCloud, permissions, rendering or exports.

Before release, verify first launch and existing-library upgrade, font/image/filter-only edits, back button and swipe navigation, failed-save retry, relaunch, empty gallery, delete/duplicate, iCloud conflict/offline/reconnect, Photos and web imports, settings/sidebar, image and video sharing, dark mode, Dynamic Type and VoiceOver on iPhone/iPad/Mac. Capture current truthful screenshots for every store slot. Complete correct privacy/web-access age declarations, contact details and support links; sign in to Xcode/ASC, export/upload/process/select and complete each platform's final submission. Automatic release should remain enabled.
