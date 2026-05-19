import XCTest

/// XCUI queries for embedded or sheet ``WebImagePicker`` chrome.
///
/// Toolbar and form actions use SF Symbols; match **accessibility labels** (localized), not visible button titles.
/// Launch with `-AppleLanguages (en)` / `-AppleLocale en_US` when tests expect English labels below.
enum WebImagePickerUIAccessibility {
    static let cancel = "Cancel"
    static let done = "Done"
    static let loadPage = "Load page"
    static let changeURL = "Change URL"
    static let navTitle = "Web images"
    static let imageMetadataSearch = "webimage.imageMetadataSearch"
}

extension XCUIApplication {
    var webImagePickerCancelButton: XCUIElement { buttons[WebImagePickerUIAccessibility.cancel] }
    var webImagePickerDoneButton: XCUIElement { buttons[WebImagePickerUIAccessibility.done] }
    var webImagePickerLoadPageButton: XCUIElement { buttons[WebImagePickerUIAccessibility.loadPage] }
    var webImagePickerChangeURLButton: XCUIElement { buttons[WebImagePickerUIAccessibility.changeURL] }
    var webImagePickerImageSearchField: XCUIElement {
        otherElements[WebImagePickerUIAccessibility.imageMetadataSearch]
    }
}
