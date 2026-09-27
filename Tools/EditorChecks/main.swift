import Foundation
import UIKit

@main struct EditorChecks {
    static func main() throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("designs")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let file = directory.appendingPathComponent("designs.json")
        try Data("[]".utf8).write(to: file)
        let manager = DesignManager(localDirectory: directory)
        var original = Design.empty
        original.text = "Synthetic editor text"
        original.creationDate = Date(timeIntervalSince1970: 1234)
        precondition(manager.addDesign(original))
        let editor = try CheckedEditor(design: original, manager: manager)
        let initial = try Data(contentsOf: file)
        precondition(editor.saveDesignIfNeeded())
        let unchanged = try Data(contentsOf: file)
        precondition(unchanged == initial)
        print("PASS unchanged editor does not rewrite saved data")

        editor.currentDesign.fontSize += 12
        precondition(editor.saveDesignIfNeeded())
        precondition(manager.getAllDesigns()[0].fontSize == editor.currentDesign.fontSize)
        editor.currentDesign.bloom = 0.4
        editor.currentDesign.backgroundFlipHorizontal = true
        editor.currentDesign.width = 720
        precondition(editor.saveDesignIfNeeded())
        let edited = manager.getAllDesigns()[0]
        precondition(edited.bloom == 0.4 && edited.backgroundFlipHorizontal && edited.width == 720)
        precondition(edited.creationDate == original.creationDate && edited.id == original.id)
        print("PASS font, filters and canvas edits persist without a text/color change; identity and creation time survive")

        editor.currentDesign.text = ""
        editor.currentDesign.backgroundImageKey = "synthetic-import"
        precondition(editor.saveDesignIfNeeded())
        precondition(manager.getAllDesigns()[0].text.isEmpty && manager.getAllDesigns()[0].backgroundImageKey == "synthetic-import")
        let fresh = try CheckedEditor(design: Design.empty, manager: manager)
        fresh.currentDesign.backgroundImageKey = "new-image-only"
        precondition(fresh.saveDesignIfNeeded())
        precondition(manager.getAllDesigns().contains { $0.id == fresh.currentDesign.id && $0.text.isEmpty })
        print("PASS cleared text and a new image-only design are saved")

        let beforeFailure = editor.lastSavedEditorContent
        let beforeFile = try Data(contentsOf: file)
        editor.currentDesign.text = "Pending unsaved edit"
        try FileManager.default.setAttributes([.immutable: true], ofItemAtPath: file.path)
        precondition(!editor.saveDesignIfNeeded())
        try FileManager.default.setAttributes([.immutable: false], ofItemAtPath: file.path)
        precondition(editor.lastSavedEditorContent == beforeFailure && !editor.errors.isEmpty)
        let preserved = try Data(contentsOf: file)
        precondition(preserved == beforeFile)
        precondition(editor.saveDesignIfNeeded())
        precondition(manager.getAllDesigns().contains { $0.id == original.id && $0.text == "Pending unsaved edit" })
        print("PASS failed save preserves the dirty marker and file; retry commits the pending edit")

        let validMarker = editor.lastSavedEditorContent
        editor.currentDesign.fontSize = .nan
        precondition(!editor.saveDesignIfNeeded() && editor.lastSavedEditorContent == validMarker)
        print("PASS encoding failure is surfaced without marking invalid data as saved")
        print("Production save decision/model/storage tested with temporary files; no native navigation or UI claim")
    }
}
