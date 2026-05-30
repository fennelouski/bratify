import Foundation

final class DesignUndoHistoryStore {
    static let shared = DesignUndoHistoryStore()

    private let queue = DispatchQueue(label: "com.bratify.DesignUndoHistoryStore", attributes: .concurrent)
    private let directoryOverride: URL?

    init(directory: URL? = nil) {
        directoryOverride = directory
    }

    private var activeDirectory: URL {
        directoryOverride ?? DesignManager.shared.activeDirectory
    }

    private func fileURL(for designID: UUID) -> URL {
        activeDirectory.appendingPathComponent("undo_\(designID.uuidString.uppercased()).json")
    }

    // MARK: - Load

    func load(for designID: UUID) -> DesignUndoHistory {
        let url = fileURL(for: designID)
        var result: DesignUndoHistory? = nil
        queue.sync {
            result = loadFromDisk(at: url, designID: designID)
        }
        return result ?? DesignUndoHistory(designID: designID)
    }

    private func loadFromDisk(at url: URL, designID: UUID) -> DesignUndoHistory? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let coordinator = NSFileCoordinator()
        var coordinatorError: NSError?
        var history: DesignUndoHistory?
        coordinator.coordinate(readingItemAt: url, options: [], error: &coordinatorError) { readURL in
            guard let data = try? Data(contentsOf: readURL) else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            history = try? decoder.decode(DesignUndoHistory.self, from: data)
        }
        return history
    }

    // MARK: - Save

    func save(_ history: DesignUndoHistory) {
        let url = fileURL(for: history.designID)
        queue.async(flags: .barrier) { [weak self] in
            self?.writeToDisk(history, at: url)
        }
    }

    private func writeToDisk(_ history: DesignUndoHistory, at url: URL) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(history) else { return }
        let coordinator = NSFileCoordinator()
        var coordinatorError: NSError?
        coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &coordinatorError) { writeURL in
            try? data.write(to: writeURL, options: .atomic)
        }
    }

    // MARK: - Delete

    func delete(for designID: UUID) {
        let url = fileURL(for: designID)
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: url.path) else { return }
            let coordinator = NSFileCoordinator()
            var coordinatorError: NSError?
            coordinator.coordinate(writingItemAt: url, options: .forDeleting, error: &coordinatorError) { deleteURL in
                try? FileManager.default.removeItem(at: deleteURL)
            }
        }
    }

    // MARK: - Purge

    func purgeAll() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            let dir = activeDirectory
            guard let contents = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return }
            for url in contents where url.lastPathComponent.hasPrefix("undo_") && url.pathExtension == "json" {
                let coordinator = NSFileCoordinator()
                var coordinatorError: NSError?
                coordinator.coordinate(writingItemAt: url, options: .forDeleting, error: &coordinatorError) { deleteURL in
                    try? FileManager.default.removeItem(at: deleteURL)
                }
            }
        }
    }

    func purgeOrphans(keeping knownIDs: Set<UUID>) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            let dir = activeDirectory
            guard let contents = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return }
            for url in contents where url.lastPathComponent.hasPrefix("undo_") && url.pathExtension == "json" {
                let name = url.deletingPathExtension().lastPathComponent  // "undo_SOME-UUID"
                let uuidString = String(name.dropFirst("undo_".count))
                guard let id = UUID(uuidString: uuidString), !knownIDs.contains(id) else { continue }
                let coordinator = NSFileCoordinator()
                var coordinatorError: NSError?
                coordinator.coordinate(writingItemAt: url, options: .forDeleting, error: &coordinatorError) { deleteURL in
                    try? FileManager.default.removeItem(at: deleteURL)
                }
            }
        }
    }
}
