import Foundation
import UIKit

// Only the image-directory integration point is linked here. Isolated managers
// return before configuring ImageService; no user images or app singleton is used.
enum ImageService { static var sharedICloudImagesDirectory: URL? }

@main struct PersistenceChecks {
    static let fm = FileManager.default
    static func main() throws {
        let root = URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("data")
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        func directory(_ name: String) throws -> URL {
            let url = root.appendingPathComponent(name)
            try fm.createDirectory(at: url, withIntermediateDirectories: true)
            return url
        }
        var original = Design.empty
        original.text = "Synthetic saved design"
        original.backgroundImageKey = "preserved-image.png"
        original.creationDate = Date(timeIntervalSince1970: 1000)
        original.modifiedDate = original.creationDate
        original.scratchIntensity = 0.7
        original.backgroundFlipHorizontal = true
        original.bloom = 0.5

        let legacy = try directory("legacy")
        try write([original], file(legacy))
        let legacyBytes = try Data(contentsOf: file(legacy))
        let manager = DesignManager(localDirectory: legacy)
        require(manager.getAllDesigns().count == 1)
        require(try encoded(manager.getAllDesigns()) == legacyBytes, "Every original-format field survives load")
        var history = DesignUndoHistory(designID: original.id)
        history.undoStack = [original]
        try write(history, undo(legacy, original.id))
        _ = manager.loadDesigns()
        require(try Data(contentsOf: file(legacy)) == legacyBytes)
        require(fm.fileExists(atPath: undo(legacy, original.id).path))
        print("PASS original array, all model fields, image reference and undo bytes survive load")

        let empty = try directory("empty")
        try write([Design](), file(empty))
        try write(history, undo(empty, original.id))
        let emptyManager = DesignManager(localDirectory: empty)
        require(emptyManager.loadDesigns().isEmpty)
        require(try Data(contentsOf: file(empty)) == Data("[]".utf8))
        require(fm.fileExists(atPath: undo(empty, original.id).path), "Initial sync must not purge unknown histories")
        print("PASS valid empty library remains empty, without samples or orphan purge")

        let fresh = try directory("fresh")
        let freshManager = DesignManager(localDirectory: fresh)
        require((4...5).contains(freshManager.getAllDesigns().count))
        require(try decode([Design].self, file(fresh)).count == freshManager.getAllDesigns().count)
        print("PASS confirmed fresh local library can still save starter designs")

        let corrupt = try directory("corrupt")
        let corruptBytes = Data("{broken existing user file".utf8)
        try corruptBytes.write(to: file(corrupt))
        try write(history, undo(corrupt, original.id))
        let damaged = DesignManager(localDirectory: corrupt)
        require(damaged.getAllDesigns().isEmpty && damaged.lastPersistenceError != nil)
        require(!damaged.addDesign(original))
        require(!damaged.deleteDesign(original))
        require(damaged.duplicateDesign(original) == nil)
        _ = damaged.loadDesigns()
        require(try Data(contentsOf: file(corrupt)) == corruptBytes)
        require(fm.fileExists(atPath: undo(corrupt, original.id).path))
        print("PASS corrupt read prevents samples and all overwriting CRUD, with visible error")

        let unreadable = try directory("unreadable")
        try write([original], file(unreadable))
        try fm.setAttributes([.posixPermissions: 0], ofItemAtPath: file(unreadable).path)
        let cannotRead = DesignManager(localDirectory: unreadable)
        require(cannotRead.lastPersistenceError != nil && !cannotRead.addDesign(original))
        try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file(unreadable).path)
        require(try Data(contentsOf: file(unreadable)) == legacyBytes)
        print("PASS actual filesystem read failure is not mistaken for missing/empty")

        let badSidecar = try directory("bad-sidecar")
        try write([original], file(badSidecar))
        try Data("bad IDs".utf8).write(to: idsFile(badSidecar))
        let badIDs = DesignManager(localDirectory: badSidecar)
        require(!badIDs.deleteDesign(original) && badIDs.lastPersistenceError != nil)
        require(try Data(contentsOf: file(badSidecar)) == legacyBytes)
        require(try Data(contentsOf: idsFile(badSidecar)) == Data("bad IDs".utf8))
        print("PASS invalid tombstone file cannot silently discard deletion history")

        let duplicates = try directory("duplicates")
        let duplicateCloud = try directory("duplicate-cloud")
        var newer = original
        newer.text = "newer duplicate"
        newer.modifiedDate = original.modifiedDate.addingTimeInterval(100)
        try write([original, newer, original], file(duplicates))
        try write([newer, original, newer], file(duplicateCloud))
        let deduplicated = DesignManager(localDirectory: duplicates, cloudDirectory: duplicateCloud)
        require(deduplicated.getAllDesigns().count == 1)
        require(deduplicated.getAllDesigns()[0].text == newer.text)
        require(try decode([Design].self, file(duplicateCloud)).count == 1)
        require(try decode([Design].self, file(duplicates)).count == 1)
        print("PASS duplicate local/cloud IDs resolve to newest modification without traps")

        let failedMarker = try directory("failed-marker")
        try write([original], file(failedMarker))
        try write([UUID](), idsFile(failedMarker))
        try write(history, undo(failedMarker, original.id))
        let markerManager = DesignManager(localDirectory: failedMarker)
        try fm.setAttributes([.immutable: true], ofItemAtPath: idsFile(failedMarker).path)
        require(!markerManager.deleteDesign(original))
        try fm.setAttributes([.immutable: false], ofItemAtPath: idsFile(failedMarker).path)
        require(markerManager.getAllDesigns().count == 1)
        require(try Data(contentsOf: file(failedMarker)) == legacyBytes)
        require(try decode([UUID].self, idsFile(failedMarker)).isEmpty)
        require(fm.fileExists(atPath: undo(failedMarker, original.id).path))
        print("PASS failed tombstone write preserves design array, memory and undo")

        let failedArray = try directory("failed-array")
        try write([original], file(failedArray))
        try write(history, undo(failedArray, original.id))
        let arrayManager = DesignManager(localDirectory: failedArray)
        try fm.setAttributes([.immutable: true], ofItemAtPath: file(failedArray).path)
        require(!arrayManager.deleteDesign(original))
        try fm.setAttributes([.immutable: false], ofItemAtPath: file(failedArray).path)
        require(arrayManager.getAllDesigns().count == 1)
        require(try Data(contentsOf: file(failedArray)) == legacyBytes)
        require(try decode(Set<UUID>.self, idsFile(failedArray)) == [original.id])
        require(fm.fileExists(atPath: undo(failedArray, original.id).path))
        let retryManager = DesignManager(localDirectory: failedArray)
        require(retryManager.getAllDesigns().isEmpty, "Durable tombstone filters partial-write stale array after restart")
        require(retryManager.deleteDesign(original))
        require(try decode([Design].self, file(failedArray)).isEmpty)
        try waitForRemoval(undo(failedArray, original.id))
        print("PASS partial array failure retains original/undo; durable tombstone prevents resurrection and retry finishes")

        let local = try directory("sync-local")
        let cloud = try directory("sync-cloud")
        try write([original], file(local))
        try write([original], file(cloud))
        try write(history, undo(cloud, original.id))
        let syncing = DesignManager(localDirectory: local, cloudDirectory: cloud)
        let brokenCloud = Data("temporarily corrupt cloud".utf8)
        try brokenCloud.write(to: file(cloud))
        require(syncing.deleteDesign(original), "Local deletion is durably saved despite pending cloud publication")
        require(syncing.getAllDesigns().isEmpty && syncing.lastPersistenceError != nil)
        require(try Data(contentsOf: file(cloud)) == brokenCloud)
        require(fm.fileExists(atPath: undo(cloud, original.id).path), "Keep undo until cloud publishing succeeds")
        require(try decode(Set<UUID>.self, idsFile(local)) == [original.id])
        try write([original], file(cloud)) // stale older client writes its original-format array
        let restarted = DesignManager(localDirectory: local, cloudDirectory: cloud)
        require(restarted.getAllDesigns().isEmpty)
        require(try decode([Design].self, file(cloud)).isEmpty)
        require(try decode(Set<UUID>.self, idsFile(cloud)) == [original.id])
        try waitForRemoval(undo(cloud, original.id))
        try write([newer], file(cloud))
        try fm.removeItem(at: idsFile(cloud)) // lost/stale cloud sidecar cannot erase local knowledge
        _ = restarted.loadDesigns()
        require(restarted.getAllDesigns().isEmpty)
        require(try decode([Design].self, file(cloud)).isEmpty)
        require(!restarted.addDesign(original), "Deleted UUID cannot be silently revived by an open editor")
        let copy = restarted.duplicateDesign(original)
        require(copy != nil && copy!.id != original.id)
        require(restarted.getAllDesigns().count == 1)
        require(try decode([Design].self, file(cloud)).first?.id == copy?.id)
        print("PASS cloud retry/restart/stale-array/stale-sidecar merge preserves deletion; explicit duplicate gets new identity")

        let artwork = try directory("artwork")
        try write([Design](), file(artwork))
        let artManager = DesignManager(localDirectory: artwork)
        var imageOnly = Design.empty
        imageOnly.backgroundImageKey = "user-image.png"
        imageOnly.text = ""
        require(artManager.addDesign(imageOnly), "Image-only new designs are valid")
        var edited = imageOnly
        edited.text = "caption"
        require(artManager.addDesign(edited), artManager.lastPersistenceError ?? "Edited save failed")
        let captionRevision = artManager.getAllDesigns()[0].modifiedDate
        edited.text = ""
        edited.brightness = 0.4
        require(artManager.addDesign(edited), "Clearing text must keep saved artwork")
        require(artManager.getAllDesigns()[0].modifiedDate > captionRevision)
        let artReopened = DesignManager(localDirectory: artwork)
        require(artReopened.getAllDesigns().count == 1)
        let savedArtwork = artReopened.getAllDesigns()[0]
        require(savedArtwork.text.isEmpty && savedArtwork.backgroundImageKey == imageOnly.backgroundImageKey && savedArtwork.brightness == 0.4)
        require(savedArtwork.creationDate.timeIntervalSince1970.rounded(.down) == imageOnly.creationDate.timeIntervalSince1970.rounded(.down))
        print("PASS new image-only designs, cleared text/filter edits and rapid revisions survive reopening")
        let legacyArtwork = try decode([LegacyDesign].self, file(artwork))
        require(legacyArtwork.count == 1 && legacyArtwork[0].backgroundImageKey == imageOnly.backgroundImageKey)
        for text in ["", "  \n\t", "\u{200B}", "\u{2060}", "visible \u{200B} text"] {
            var sample = original
            sample.text = text
            let wire = try encoded(sample)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let restored = try decoder.decode(Design.self, from: wire)
            let oldReader = try decoder.decode(LegacyDesign.self, from: wire)
            require(restored.text == text, "Exact blank, whitespace and user zero-width characters must round-trip")
            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                require(oldReader.text == text, "Nonblank text must never be changed for compatibility")
            }
        }
        print("PASS actual baseline decoder reads new blank-artwork wire format; whitespace and user zero-width text round-trip exactly")

        let lateDelete = try directory("late-delete")
        try write([original], file(lateDelete))
        let openEditor = DesignManager(localDirectory: lateDelete)
        try write([original.id], idsFile(lateDelete))
        require(!openEditor.addDesign(original), "A tombstone arriving after editor opens must prevent resurrection")
        require(openEditor.getAllDesigns().isEmpty && openEditor.lastPersistenceError != nil)
        print("PASS coordinated save detects newly arrived deletion before publishing stale editor content")

        require(ImageService.sharedICloudImagesDirectory == nil)
        print("PASS all 13 persistence scenarios; original UIKit/Design/manager/undo source, synthetic local/cloud directories only; no shared manager, real Documents, iCloud account, Simulator or UI")
    }

    static func file(_ dir: URL) -> URL { dir.appendingPathComponent("designs.json") }
    static func idsFile(_ dir: URL) -> URL { dir.appendingPathComponent("deleted-design-ids.json") }
    static func undo(_ dir: URL, _ id: UUID) -> URL { dir.appendingPathComponent("undo_\(id.uuidString.uppercased()).json") }
    static func encoded<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }
    static func write<T: Encodable>(_ value: T, _ url: URL) throws { try encoded(value).write(to: url) }
    static func decode<T: Decodable>(_ type: T.Type, _ url: URL) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: Data(contentsOf: url))
    }
    static func waitForRemoval(_ url: URL) throws {
        let deadline = Date().addingTimeInterval(3)
        while fm.fileExists(atPath: url.path) && Date() < deadline { Thread.sleep(forTimeInterval: 0.01) }
        require(!fm.fileExists(atPath: url.path), "Committed delete must remove corresponding undo history")
    }
}

func require(_ value: @autoclosure () throws -> Bool, _ message: String = "Invariant failed", line: UInt = #line) {
    do {
        if try value() { return }
        print("FAIL line \(line): \(message)")
    } catch {
        print("FAIL line \(line): \(error)")
    }
    fflush(stdout)
    exit(1)
}
