//
//  DesignUndoHistoryStoreTests.swift
//  bratTests
//

import XCTest
@testable import brat

final class DesignUndoHistoryStoreTests: XCTestCase {

    private var tempDir: URL!
    private var store: DesignUndoHistoryStore!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        store = DesignUndoHistoryStore(directory: tempDir)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    private func makeDesign(text: String) -> Design {
        Design(
            text: text,
            backgroundColor: .green,
            creationDate: Date(),
            fontName: "Arial",
            fontSize: 48,
            pixelationScale: 8
        )
    }

    private func makeHistory(designID: UUID, undoTexts: [String], redoTexts: [String] = []) -> DesignUndoHistory {
        var h = DesignUndoHistory(designID: designID)
        h.undoStack = undoTexts.map { makeDesign(text: $0) }
        h.redoStack = redoTexts.map { makeDesign(text: $0) }
        return h
    }

    // MARK: - Save and Load

    func testSaveAndLoad() {
        let id = UUID()
        let history = makeHistory(designID: id, undoTexts: ["a", "b", "c"], redoTexts: ["d"])
        store.save(history)
        Thread.sleep(forTimeInterval: 0.1) // let async write finish

        let loaded = store.load(for: id)
        XCTAssertEqual(loaded.undoStack.map(\.text), ["a", "b", "c"])
        XCTAssertEqual(loaded.redoStack.map(\.text), ["d"])
        XCTAssertEqual(loaded.designID, id)
    }

    func testLoadMissingReturnsEmptyHistory() {
        let id = UUID()
        let loaded = store.load(for: id)
        XCTAssertEqual(loaded.designID, id)
        XCTAssertTrue(loaded.undoStack.isEmpty)
        XCTAssertTrue(loaded.redoStack.isEmpty)
    }

    // MARK: - Delete

    func testDeleteRemovesFile() {
        let id = UUID()
        let history = makeHistory(designID: id, undoTexts: ["x"])
        store.save(history)
        Thread.sleep(forTimeInterval: 0.1)

        let filePath = tempDir.appendingPathComponent("undo_\(id.uuidString.uppercased()).json").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: filePath))

        store.delete(for: id)
        Thread.sleep(forTimeInterval: 0.1)
        XCTAssertFalse(FileManager.default.fileExists(atPath: filePath))
    }

    // MARK: - Purge

    func testPurgeAllRemovesAllUndoFiles() {
        let ids = [UUID(), UUID(), UUID()]
        for id in ids {
            store.save(makeHistory(designID: id, undoTexts: ["step"]))
        }
        Thread.sleep(forTimeInterval: 0.1)

        store.purgeAll()
        Thread.sleep(forTimeInterval: 0.1)

        for id in ids {
            let path = tempDir.appendingPathComponent("undo_\(id.uuidString.uppercased()).json").path
            XCTAssertFalse(FileManager.default.fileExists(atPath: path))
        }
    }

    func testPurgeOrphansKeepsKnownIDs() {
        let kept = UUID()
        let orphan = UUID()
        store.save(makeHistory(designID: kept, undoTexts: ["keep"]))
        store.save(makeHistory(designID: orphan, undoTexts: ["orphan"]))
        Thread.sleep(forTimeInterval: 0.1)

        store.purgeOrphans(keeping: [kept])
        Thread.sleep(forTimeInterval: 0.1)

        let keptPath = tempDir.appendingPathComponent("undo_\(kept.uuidString.uppercased()).json").path
        let orphanPath = tempDir.appendingPathComponent("undo_\(orphan.uuidString.uppercased()).json").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: keptPath), "Known design file should remain")
        XCTAssertFalse(FileManager.default.fileExists(atPath: orphanPath), "Orphan file should be deleted")
    }

    // MARK: - Schema migration

    func testSchemaVersionMigrationResetsStacks() {
        let id = UUID()
        // Write a JSON that looks like schema version 0
        let json = """
        {"designID":"\(id.uuidString)","schemaVersion":0,"undoStack":[],"redoStack":[]}
        """.data(using: .utf8)!
        let path = tempDir.appendingPathComponent("undo_\(id.uuidString.uppercased()).json")
        try? json.write(to: path, options: .atomic)

        let loaded = store.load(for: id)
        XCTAssertTrue(loaded.undoStack.isEmpty)
        XCTAssertTrue(loaded.redoStack.isEmpty)
    }
}
