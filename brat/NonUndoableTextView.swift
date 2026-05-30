import UIKit

// Returns a private no-op UndoManager so UIKit's character-level undo doesn't intercept
// ⌘Z. Design-level undo (EditDesignViewController) handles ⌘Z for all editor state,
// including text. Text edits are coalesced per editing session via textViewDidBeginEditing
// / textViewDidEndEditing.
final class NonUndoableTextView: UITextView {
    private let _noOp = UndoManager()
    override var undoManager: UndoManager? { _noOp }
}
