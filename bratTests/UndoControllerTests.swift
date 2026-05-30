//
//  UndoControllerTests.swift
//  bratTests
//

import XCTest
@testable import brat

final class UndoControllerTests: XCTestCase {

    private func makeDesign(text: String, brightness: CGFloat = 0) -> Design {
        Design(
            text: text,
            backgroundColor: .green,
            creationDate: Date(),
            fontName: "Arial",
            fontSize: 48,
            pixelationScale: 8,
            brightness: brightness
        )
    }

    private func makeController(maxSteps: Int = 50) -> DesignUndoController {
        let history = DesignUndoHistory(designID: UUID())
        return DesignUndoController(history: history, maxSteps: maxSteps)
    }

    // MARK: - Basic stack behaviour

    func testRecordPushesUndoStack() {
        let ctrl = makeController()
        let s1 = makeDesign(text: "a")
        let s2 = makeDesign(text: "b")
        ctrl.record(s1)
        ctrl.record(s2)
        XCTAssertEqual(ctrl.history.undoStack.count, 2)
        XCTAssertTrue(ctrl.canUndo)
        XCTAssertFalse(ctrl.canRedo)
    }

    func testUndoReturnsPreviousSnapshot() {
        let ctrl = makeController()
        let s0 = makeDesign(text: "initial")
        let s1 = makeDesign(text: "edited")
        ctrl.record(s0)
        let restored = ctrl.undo(currentDesign: s1)
        XCTAssertEqual(restored?.text, "initial")
    }

    func testUndoPushesCurrentOntoRedoStack() {
        let ctrl = makeController()
        let s0 = makeDesign(text: "initial")
        let s1 = makeDesign(text: "edited")
        ctrl.record(s0)
        _ = ctrl.undo(currentDesign: s1)
        XCTAssertTrue(ctrl.canRedo)
        XCTAssertFalse(ctrl.canUndo)
        XCTAssertEqual(ctrl.history.redoStack.last?.text, "edited")
    }

    func testRedoRestoresUndoneSnapshot() {
        let ctrl = makeController()
        let s0 = makeDesign(text: "base")
        let s1 = makeDesign(text: "edited")
        ctrl.record(s0)
        _ = ctrl.undo(currentDesign: s1)
        let redone = ctrl.redo(currentDesign: s0)
        XCTAssertEqual(redone?.text, "edited")
        XCTAssertTrue(ctrl.canUndo)
        XCTAssertFalse(ctrl.canRedo)
    }

    func testRedoStackClearedOnRecord() {
        let ctrl = makeController()
        let s0 = makeDesign(text: "base")
        let s1 = makeDesign(text: "edited")
        let s2 = makeDesign(text: "new edit")
        ctrl.record(s0)
        _ = ctrl.undo(currentDesign: s1)
        // New edit after undo should clear redo
        ctrl.record(s1)
        XCTAssertFalse(ctrl.canRedo)
        // s2 is now current; undo should restore s1
        let restored = ctrl.undo(currentDesign: s2)
        XCTAssertEqual(restored?.text, "edited")
    }

    // MARK: - Trimming

    func testUndoStackTrimsToMaxSteps() {
        let ctrl = makeController(maxSteps: 5)
        for i in 0..<10 {
            ctrl.record(makeDesign(text: "step \(i)"))
        }
        XCTAssertEqual(ctrl.history.undoStack.count, 5)
        // Oldest entries should have been discarded
        XCTAssertEqual(ctrl.history.undoStack.first?.text, "step 5")
    }

    func testMaxStepsOfOne() {
        let ctrl = makeController(maxSteps: 1)
        ctrl.record(makeDesign(text: "first"))
        ctrl.record(makeDesign(text: "second"))
        XCTAssertEqual(ctrl.history.undoStack.count, 1)
        XCTAssertEqual(ctrl.history.undoStack.first?.text, "second")
    }

    func testReducingMaxStepsTrimsExistingStack() {
        let ctrl = makeController(maxSteps: 20)
        for i in 0..<15 {
            ctrl.record(makeDesign(text: "step \(i)"))
        }
        XCTAssertEqual(ctrl.history.undoStack.count, 15)
        ctrl.maxSteps = 5
        XCTAssertEqual(ctrl.history.undoStack.count, 5)
    }

    // MARK: - Coalescing

    func testContinuousEditCoalescesToOneStep() {
        let ctrl = makeController()
        let base = makeDesign(text: "base")
        let mid = makeDesign(text: "mid", brightness: 0.5)
        ctrl.willBeginContinuousEdit(currentDesign: base)
        // Simulate many intermediate slider updates — none should push to undo stack
        for _ in 0..<10 {
            ctrl.willBeginContinuousEdit(currentDesign: mid) // nested: ignored
        }
        ctrl.didEndContinuousEdit()
        XCTAssertEqual(ctrl.history.undoStack.count, 1)
        XCTAssertEqual(ctrl.history.undoStack.first?.text, "base")
    }

    func testNestedBeginIsIgnored() {
        let ctrl = makeController()
        let s0 = makeDesign(text: "first")
        let s1 = makeDesign(text: "second")
        ctrl.willBeginContinuousEdit(currentDesign: s0)
        ctrl.willBeginContinuousEdit(currentDesign: s1) // should be ignored
        ctrl.didEndContinuousEdit()
        // Only one entry from the first begin
        XCTAssertEqual(ctrl.history.undoStack.count, 1)
        XCTAssertEqual(ctrl.history.undoStack.first?.text, "first")
    }

    func testEndWithoutBeginIsNoOp() {
        let ctrl = makeController()
        ctrl.didEndContinuousEdit()
        XCTAssertFalse(ctrl.canUndo)
    }

    // MARK: - Edge cases

    func testUndoOnEmptyStackReturnsNil() {
        let ctrl = makeController()
        let result = ctrl.undo(currentDesign: makeDesign(text: "current"))
        XCTAssertNil(result)
    }

    func testRedoOnEmptyStackReturnsNil() {
        let ctrl = makeController()
        let result = ctrl.redo(currentDesign: makeDesign(text: "current"))
        XCTAssertNil(result)
    }
}
