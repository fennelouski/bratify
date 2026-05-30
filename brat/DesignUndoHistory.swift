import Foundation

struct DesignUndoHistory: Codable {
    static let currentSchemaVersion = 1

    var designID: UUID
    var undoStack: [Design]
    var redoStack: [Design]
    var schemaVersion: Int

    init(designID: UUID) {
        self.designID = designID
        self.undoStack = []
        self.redoStack = []
        self.schemaVersion = Self.currentSchemaVersion
    }

    enum CodingKeys: String, CodingKey {
        case designID, undoStack, redoStack, schemaVersion
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(designID, forKey: .designID)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(undoStack, forKey: .undoStack)
        try container.encode(redoStack, forKey: .redoStack)
    }

    // Wraps individual Design decodes so one bad snapshot doesn't wipe the whole stack.
    private struct FailableDesign: Decodable {
        let design: Design?
        init(from decoder: Decoder) throws {
            design = try? Design(from: decoder)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        designID = try container.decode(UUID.self, forKey: .designID)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 0

        if schemaVersion < Self.currentSchemaVersion {
            undoStack = []
            redoStack = []
            return
        }

        let failableUndo = try container.decodeIfPresent([FailableDesign].self, forKey: .undoStack) ?? []
        let failableRedo = try container.decodeIfPresent([FailableDesign].self, forKey: .redoStack) ?? []
        undoStack = failableUndo.compactMap(\.design)
        redoStack = failableRedo.compactMap(\.design)
    }
}
