import UIKit

extension Notification.Name {
    static let designSaveFailed = Notification.Name("com.bratify.designSaveFailed")
    static let designsDidSync = Notification.Name("com.bratify.designsDidSync")
}

class DesignManager {

    static let shared = DesignManager()

    private let designsFileName = "designs.json"
    private var designs: [Design] = []
    private var metadataQuery: NSMetadataQuery?
    private var iCloudDocumentsURL: URL?

    init() {
        designs = loadFromDisk(at: localFileURL)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let containerURL = FileManager.default
                .url(forUbiquityContainerIdentifier: "iCloud.com.nathanfennel.brat")?
                .appendingPathComponent("Documents")

            if let containerURL {
                try? FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
            }

            DispatchQueue.main.async {
                self.iCloudDocumentsURL = containerURL
                self.migrateLocalToiCloudIfNeeded()
                self.setupiCloudObserver()
            }
        }
    }

    // MARK: - URLs

    private var localFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(designsFileName)
    }

    private var iCloudFileURL: URL? {
        iCloudDocumentsURL?.appendingPathComponent(designsFileName)
    }

    private var activeFileURL: URL {
        iCloudFileURL ?? localFileURL
    }

    // MARK: - Migration

    private func migrateLocalToiCloudIfNeeded() {
        guard let iCloudURL = iCloudFileURL else { return }
        let local = localFileURL
        guard !FileManager.default.fileExists(atPath: iCloudURL.path),
              FileManager.default.fileExists(atPath: local.path) else { return }

        let coordinator = NSFileCoordinator()
        var error: NSError?
        coordinator.coordinate(
            writingItemAt: local, options: .forMoving,
            writingItemAt: iCloudURL, options: .forReplacing,
            error: &error
        ) { srcURL, dstURL in
            try? FileManager.default.moveItem(at: srcURL, to: dstURL)
        }
    }

    // MARK: - iCloud Observer

    private func setupiCloudObserver() {
        guard iCloudDocumentsURL != nil else { return }

        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemFSNameKey, designsFileName)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleMetadataUpdate),
            name: .NSMetadataQueryDidFinishGathering, object: query
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleMetadataUpdate),
            name: .NSMetadataQueryDidUpdate, object: query
        )

        query.start()
        self.metadataQuery = query
    }

    @objc private func handleMetadataUpdate(_ notification: Notification) {
        metadataQuery?.disableUpdates()
        defer { metadataQuery?.enableUpdates() }

        guard let iCloudURL = iCloudFileURL else { return }
        let remoteDesigns = loadFromDisk(at: iCloudURL)
        guard !remoteDesigns.isEmpty else { return }

        let merged = merge(local: designs, remote: remoteDesigns)

        let hasChanges = merged.count != designs.count ||
            merged.contains(where: { remote in
                designs.first(where: { $0.id == remote.id })?.modifiedDate != remote.modifiedDate
            })

        guard hasChanges else { return }
        designs = merged
        writeToDisk(merged, at: iCloudURL)
        NotificationCenter.default.post(name: .designsDidSync, object: nil)
    }

    private func merge(local: [Design], remote: [Design]) -> [Design] {
        var byID = Dictionary(uniqueKeysWithValues: local.map { ($0.id, $0) })
        for design in remote {
            if let existing = byID[design.id] {
                if design.modifiedDate > existing.modifiedDate {
                    byID[design.id] = design
                }
            } else {
                byID[design.id] = design
            }
        }
        return byID.values.sorted { $0.creationDate < $1.creationDate }
    }

    // MARK: - CRUD

    func addDesign(_ design: Design) {
        if let index = designs.firstIndex(where: { $0.id == design.id }) {
            var updated = design
            updated.modifiedDate = Date()
            designs[index] = updated
        } else if !design.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            designs.append(design)
        }
        saveDesigns(designs)
    }

    func deleteDesign(_ design: Design) {
        if let index = designs.firstIndex(where: { $0.id == design.id }) {
            designs.remove(at: index)
            saveDesigns(designs)
        }
    }

    @discardableResult
    func duplicateDesign(_ design: Design) -> Design {
        var duplicate = design
        duplicate.id = UUID()
        duplicate.creationDate = Date()
        if let index = designs.firstIndex(where: { $0.id == design.id }) {
            designs.insert(duplicate, at: index + 1)
        } else {
            designs.append(duplicate)
        }
        saveDesigns(designs)
        return duplicate
    }

    func getAllDesigns() -> [Design] {
        return designs
    }

    func loadDesigns() -> [Design] {
        let loaded = loadFromDisk(at: activeFileURL)
        if loaded.isEmpty {
            designs = generateRandomDesigns(count: .random(in: 4...5))
        } else {
            designs = loaded
        }
        return designs
    }

    // MARK: - Persistence

    private func loadFromDisk(at url: URL) -> [Design] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var result: [Design] = []
        let coordinator = NSFileCoordinator()
        var coordinatorError: NSError?
        coordinator.coordinate(readingItemAt: url, options: [], error: &coordinatorError) { readURL in
            guard let data = try? Data(contentsOf: readURL),
                  let decoded = try? decoder.decode([Design].self, from: data) else { return }
            result = decoded
        }
        return result
    }

    private func saveDesigns(_ designs: [Design]) {
        if let url = iCloudFileURL {
            writeToDisk(designs, at: url)
        } else {
            writeToDisk(designs, at: localFileURL)
        }
    }

    private func writeToDisk(_ designs: [Design], at url: URL) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(designs) else {
            NotificationCenter.default.post(name: .designSaveFailed, object: nil)
            return
        }
        let coordinator = NSFileCoordinator()
        var coordinatorError: NSError?
        coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &coordinatorError) { writeURL in
            do {
                try data.write(to: writeURL, options: .atomic)
            } catch {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .designSaveFailed, object: nil)
                }
            }
        }
        if let coordinatorError {
            print("File coordination error: \(coordinatorError.localizedDescription)")
            NotificationCenter.default.post(name: .designSaveFailed, object: nil)
        }
    }

    // MARK: - Sample Data

    func generateRandomDesigns(count: Int) -> [Design] {
        let texts = [
            NSLocalizedString("you", comment: "The first word in the five word phrase \"you can figure it out\""),
            NSLocalizedString("can", comment: "The second word in the five word phrase \"you can figure it out\""),
            NSLocalizedString("do", comment: "the verb \"to do\""),
            NSLocalizedString("it", comment: "The third word in the five word phrase \"you can figure it out\""),
            NSLocalizedString("figure", comment: "The fourth word in the five word phrase \"you can figure it out\""),
            NSLocalizedString("out", comment: "The fifth word in the five word phrase \"you can figure it out\""),
            NSLocalizedString("k", comment: "short for \"okay\"")
        ]
        var designs: [Design] = []

        for i in 0..<count {
            let text = texts[i % texts.count]
            let backgroundColor = UIColor(
                red: CGFloat.random(in: 0.7...1.0),
                green: CGFloat.random(in: 0.7...1.0),
                blue: CGFloat.random(in: 0.7...1.0),
                alpha: 1.0
            )
            let design = Design(
                text: text,
                backgroundColor: backgroundColor,
                creationDate: Date(),
                fontName: "Arial",
                fontSize: CGFloat.random(in: 40...180),
                pixelationScale: CGFloat.random(in: 5...12),
                stretch: 0.2,
                blur: .random(in: 0...0.001),
                id: UUID()
            )
            designs.append(design)
        }

        return designs
    }
}
