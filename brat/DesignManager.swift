import UIKit

extension Notification.Name {
    static let designSaveFailed = Notification.Name("com.bratify.designSaveFailed")
    static let designsDidSync = Notification.Name("com.bratify.designsDidSync")
    static let designsInitialSyncDidComplete = Notification.Name("com.bratify.designsInitialSyncDidComplete")
}

class DesignManager {

    static let shared = DesignManager()

    private let designsFileName = "designs.json"
    private let initialSyncTimeout: TimeInterval = 20

    private var designs: [Design] = []
    private var metadataQuery: NSMetadataQuery?
    private var iCloudDocumentsURL: URL?
    private var hasCompletedInitialSync = false
    private var initialSyncTimeoutWorkItem: DispatchWorkItem?

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
                if let imagesDir = containerURL?.appendingPathComponent("Images") {
                    try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
                    ImageService.sharedICloudImagesDirectory = imagesDir
                }
                self.migrateLocalToiCloudIfNeeded()
                self.setupiCloudObserver()
                self.beginInitialSyncCheck()
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

    var activeDirectory: URL {
        activeFileURL.deletingLastPathComponent()
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

    // MARK: - Initial Sync

    private func beginInitialSyncCheck() {
        scheduleInitialSyncTimeout()

        guard iCloudDocumentsURL != nil, let iCloudURL = iCloudFileURL else {
            finishInitialSyncIfNeeded()
            return
        }

        guard FileManager.default.fileExists(atPath: iCloudURL.path) else {
            finishInitialSyncIfNeeded()
            return
        }

        try? FileManager.default.startDownloadingUbiquitousItem(at: iCloudURL)

        if isRemoteFileReadyForRead() {
            _ = attemptMergeFromiCloud()
            finishInitialSyncIfNeeded()
        }
    }

    private func scheduleInitialSyncTimeout() {
        initialSyncTimeoutWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.finishInitialSyncIfNeeded()
        }
        initialSyncTimeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + initialSyncTimeout, execute: workItem)
    }

    private func cancelInitialSyncTimeout() {
        initialSyncTimeoutWorkItem?.cancel()
        initialSyncTimeoutWorkItem = nil
    }

    private func finishInitialSyncIfNeeded() {
        guard !hasCompletedInitialSync else { return }
        hasCompletedInitialSync = true
        cancelInitialSyncTimeout()

        if let iCloudURL = iCloudFileURL,
           FileManager.default.fileExists(atPath: iCloudURL.path),
           isRemoteFileReadyForRead() {
            _ = attemptMergeFromiCloud()
        }

        let loaded = loadFromDisk(at: activeFileURL)
        if !loaded.isEmpty {
            designs = loaded
        } else if designs.isEmpty {
            designs = generateRandomDesigns(count: .random(in: 4...5))
            saveDesigns(designs)
        }

        NotificationCenter.default.post(name: .designsInitialSyncDidComplete, object: nil)

        let knownIDs = Set(designs.map(\.id))
        DesignUndoHistoryStore.shared.purgeOrphans(keeping: knownIDs)
    }

    private func ubiquitousDownloadStatus() -> String? {
        guard let results = metadataQuery?.results as? [NSMetadataItem] else { return nil }
        let item = results.first { metadataItem in
            (metadataItem.value(forAttribute: NSMetadataItemFSNameKey) as? String) == designsFileName
        }
        return item?.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String
    }

    private func isRemoteFileReadyForRead() -> Bool {
        if let status = ubiquitousDownloadStatus() {
            return status == NSMetadataUbiquitousItemDownloadingStatusCurrent
                || status == NSMetadataUbiquitousItemDownloadingStatusDownloaded
        }
        guard let iCloudURL = iCloudFileURL else { return false }
        return FileManager.default.fileExists(atPath: iCloudURL.path)
    }

    @discardableResult
    private func attemptMergeFromiCloud() -> Bool {
        guard let iCloudURL = iCloudFileURL else { return false }
        let remoteDesigns = loadFromDisk(at: iCloudURL)
        guard !remoteDesigns.isEmpty else { return false }

        let merged = merge(local: designs, remote: remoteDesigns)
        guard designsChanged(from: designs, to: merged) else { return false }

        designs = merged
        writeToDisk(merged, at: iCloudURL)
        return true
    }

    private func designsChanged(from current: [Design], to merged: [Design]) -> Bool {
        merged.count != current.count ||
            merged.contains { design in
                current.first(where: { $0.id == design.id })?.modifiedDate != design.modifiedDate
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

        if !hasCompletedInitialSync {
            processInitialSyncMetadataUpdate()
            return
        }

        guard let iCloudURL = iCloudFileURL else { return }
        guard isRemoteFileReadyForRead() else {
            try? FileManager.default.startDownloadingUbiquitousItem(at: iCloudURL)
            return
        }

        guard attemptMergeFromiCloud() else { return }
        NotificationCenter.default.post(name: .designsDidSync, object: nil)
    }

    private func processInitialSyncMetadataUpdate() {
        guard let iCloudURL = iCloudFileURL else {
            finishInitialSyncIfNeeded()
            return
        }

        guard FileManager.default.fileExists(atPath: iCloudURL.path) else {
            finishInitialSyncIfNeeded()
            return
        }

        if !isRemoteFileReadyForRead() {
            try? FileManager.default.startDownloadingUbiquitousItem(at: iCloudURL)
            return
        }

        _ = attemptMergeFromiCloud()
        finishInitialSyncIfNeeded()
    }

    func merge(local: [Design], remote: [Design]) -> [Design] {
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
            DesignUndoHistoryStore.shared.delete(for: design.id)
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

    func loadDesigns(allowSampleGeneration: Bool = true) -> [Design] {
        let loaded = loadFromDisk(at: activeFileURL)
        if loaded.isEmpty {
            if allowSampleGeneration {
                designs = generateRandomDesigns(count: .random(in: 4...5))
                saveDesigns(designs)
            } else {
                designs = []
            }
        } else {
            designs = loaded
        }
        return designs
    }

    // MARK: - Persistence

    private func loadFromDisk(at url: URL) -> [Design] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }

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
