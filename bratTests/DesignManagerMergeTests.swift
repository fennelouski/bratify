//
//  DesignManagerMergeTests.swift
//  bratTests
//

import XCTest
@testable import brat

final class DesignManagerMergeTests: XCTestCase {

    private func makeDesign(
        text: String,
        id: UUID = UUID(),
        creationDate: Date,
        modifiedDate: Date
    ) -> Design {
        Design(
            text: text,
            backgroundColor: .green,
            creationDate: creationDate,
            modifiedDate: modifiedDate,
            fontName: "Arial",
            fontSize: 48,
            pixelationScale: 8,
            id: id
        )
    }

    func testMergePrefersNewerRemoteModifiedDate() {
        let id = UUID()
        let base = Date(timeIntervalSince1970: 1_000_000)
        let local = makeDesign(text: "local", id: id, creationDate: base, modifiedDate: base)
        let remote = makeDesign(
            text: "remote",
            id: id,
            creationDate: base,
            modifiedDate: base.addingTimeInterval(60)
        )

        let merged = DesignManager.shared.merge(local: [local], remote: [remote])
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].text, "remote")
    }

    func testMergeKeepsLocalWhenNewerThanRemote() {
        let id = UUID()
        let base = Date(timeIntervalSince1970: 1_000_000)
        let local = makeDesign(
            text: "local",
            id: id,
            creationDate: base,
            modifiedDate: base.addingTimeInterval(120)
        )
        let remote = makeDesign(
            text: "remote",
            id: id,
            creationDate: base,
            modifiedDate: base.addingTimeInterval(60)
        )

        let merged = DesignManager.shared.merge(local: [local], remote: [remote])
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].text, "local")
    }

    func testMergeAppendsDesignsOnlyOnRemote() {
        let older = Date(timeIntervalSince1970: 1_000_000)
        let newer = older.addingTimeInterval(100)
        let local = makeDesign(text: "a", creationDate: older, modifiedDate: older)
        let remoteOnly = makeDesign(text: "b", creationDate: newer, modifiedDate: newer)

        let merged = DesignManager.shared.merge(local: [local], remote: [remoteOnly])
        XCTAssertEqual(merged.count, 2)
        XCTAssertEqual(merged.map(\.text), ["a", "b"])
    }

    func testMergeSortsByCreationDateAscending() {
        let first = Date(timeIntervalSince1970: 100)
        let second = Date(timeIntervalSince1970: 200)
        let third = Date(timeIntervalSince1970: 300)
        let designs = [
            makeDesign(text: "c", creationDate: third, modifiedDate: third),
            makeDesign(text: "a", creationDate: first, modifiedDate: first),
            makeDesign(text: "b", creationDate: second, modifiedDate: second),
        ]

        let merged = DesignManager.shared.merge(local: designs, remote: [])
        XCTAssertEqual(merged.map(\.text), ["a", "b", "c"])
    }
}
