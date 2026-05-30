import Foundation

final class DesignUndoController {

    // MARK: - Configuration

    var maxSteps: Int {
        didSet { trim() }
    }

    // MARK: - State

    private(set) var history: DesignUndoHistory

    var canUndo: Bool { !history.undoStack.isEmpty }
    var canRedo: Bool { !history.redoStack.isEmpty }

    // MARK: - Coalescing

    private var pendingContinuousEditSnapshot: Design?

    // MARK: - Init

    init(history: DesignUndoHistory, maxSteps: Int) {
        self.history = history
        self.maxSteps = maxSteps
        trim()
    }

    // MARK: - Recording

    /// Push a snapshot taken immediately *before* a discrete edit.
    /// Clears the redo stack — new edits always invalidate the redo branch.
    func record(_ snapshot: Design) {
        history.undoStack.append(snapshot)
        history.redoStack.removeAll()
        trim()
    }

    // MARK: - Undo / Redo

    /// Returns the snapshot to restore, or nil if the undo stack is empty.
    /// Pushes `currentDesign` onto the redo stack.
    func undo(currentDesign: Design) -> Design? {
        guard canUndo else { return nil }
        let restored = history.undoStack.removeLast()
        history.redoStack.append(currentDesign)
        trimRedo()
        return restored
    }

    /// Returns the snapshot to restore, or nil if the redo stack is empty.
    /// Pushes `currentDesign` onto the undo stack.
    func redo(currentDesign: Design) -> Design? {
        guard canRedo else { return nil }
        let restored = history.redoStack.removeLast()
        history.undoStack.append(currentDesign)
        trim()
        return restored
    }

    // MARK: - Coalescing (slider / text session)

    /// Call when a continuous gesture (slider drag, text editing) begins.
    /// Captures a pre-gesture snapshot. Nested calls before `didEndContinuousEdit` are ignored.
    func willBeginContinuousEdit(currentDesign: Design) {
        if pendingContinuousEditSnapshot == nil {
            pendingContinuousEditSnapshot = currentDesign
        }
    }

    /// Call when the gesture ends. Pushes the pre-gesture snapshot (if any) onto the undo stack.
    func didEndContinuousEdit() {
        guard let snapshot = pendingContinuousEditSnapshot else { return }
        pendingContinuousEditSnapshot = nil
        record(snapshot)
    }

    // MARK: - Private

    private func trim() {
        while history.undoStack.count > maxSteps {
            history.undoStack.removeFirst()
        }
    }

    private func trimRedo() {
        while history.redoStack.count > maxSteps {
            history.redoStack.removeFirst()
        }
    }
}
