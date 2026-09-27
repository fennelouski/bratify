import UIKit

extension Notification.Name {
    static let designSaveFailed = Notification.Name("com.bratify.designSaveFailed")
    static let designsDidSync = Notification.Name("com.bratify.designsDidSync")
    static let designsInitialSyncDidComplete = Notification.Name("com.bratify.designsInitialSyncDidComplete")
}

class DesignManager {
    static let shared = DesignManager()

    private let designsFileName = "designs.json"
    private let deletedIDsFileName = "deleted-design-ids.json"
    private let initialSyncTimeout: TimeInterval = 20
    private let localDirectory: URL
    private let usesIsolatedDirectories: Bool
    private var designs: [Design] = []
    private var deletedIDs = Set<UUID>()
    private var metadataQuery: NSMetadataQuery?
    private var iCloudDocumentsURL: URL?
    private var hasCompletedInitialSync = false
    private var hasGatheredCloudMetadata = false
    private var initialSyncTimeoutWorkItem: DispatchWorkItem?
    private(set) var lastPersistenceError: String?
    private lazy var undoHistoryStore = usesIsolatedDirectories
        ? DesignUndoHistoryStore(directory: activeDirectory) : DesignUndoHistoryStore.shared

    // Explicit directories keep development checks out of real Documents/iCloud.
    init(localDirectory: URL? = nil, cloudDirectory: URL? = nil) {
        self.localDirectory = localDirectory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        usesIsolatedDirectories = localDirectory != nil
        do {
            let local = try readFromDisk(at: localFileURL)
            deletedIDs = local.deletedIDs
            designs = merge(local: local.designs, remote: [])
        } catch {
            reportFailure(error, operation: "Could not read saved designs. The existing files were left unchanged.")
        }
        if usesIsolatedDirectories {
            iCloudDocumentsURL = cloudDirectory
            finishInitialSyncIfNeeded()
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let containerURL = FileManager.default
                .url(forUbiquityContainerIdentifier: "iCloud.com.nathanfennel.brat")?
                .appendingPathComponent("Documents")
            DispatchQueue.main.async {
                guard let self else { return }
                self.iCloudDocumentsURL = containerURL
                if let containerURL {
                    do {
                        try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
                        let imagesDir = containerURL.appendingPathComponent("Images")
                        try FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
                        ImageService.sharedICloudImagesDirectory = imagesDir
                    } catch {
                        self.reportFailure(error, operation: "Could not prepare iCloud storage. Local designs are preserved.")
                    }
                }
                self.setupiCloudObserver()
                self.beginInitialSyncCheck()
            }
        }
    }

    private var localFileURL: URL { localDirectory.appendingPathComponent(designsFileName) }
    private var iCloudFileURL: URL? { iCloudDocumentsURL?.appendingPathComponent(designsFileName) }
    var activeDirectory: URL { iCloudDocumentsURL ?? localDirectory }

    // MARK: - Initial Sync

    private func beginInitialSyncCheck() {
        let workItem = DispatchWorkItem { [weak self] in self?.finishInitialSyncIfNeeded() }
        initialSyncTimeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + initialSyncTimeout, execute: workItem)
        if iCloudDocumentsURL == nil || isRemoteFileReadyForRead() {
            finishInitialSyncIfNeeded()
        } else {
            requestCloudDownloads()
        }
    }

    private func finishInitialSyncIfNeeded() {
        guard !hasCompletedInitialSync else { return }
        hasCompletedInitialSync = true
        initialSyncTimeoutWorkItem?.cancel()
        initialSyncTimeoutWorkItem = nil
        _ = loadDesigns()
        NotificationCenter.default.post(name: .designsInitialSyncDidComplete, object: self)
        // A timed-out cloud download is not evidence that its undo files are orphans.
        // Only an explicitly committed deletion may remove an undo history.
    }

    private func requestCloudDownloads() {
        guard let directory = iCloudDocumentsURL else { return }
        for name in [designsFileName, deletedIDsFileName] {
            let url = directory.appendingPathComponent(name)
            if FileManager.default.fileExists(atPath: url.path) {
                do { try FileManager.default.startDownloadingUbiquitousItem(at: url) }
                catch { reportFailure(error, operation: "Could not download iCloud designs. Local designs are preserved.") }
            }
        }
    }

    private func isRemoteFileReadyForRead() -> Bool {
        guard let directory = iCloudDocumentsURL else { return false }
        // A missing local URL before the initial metadata query finishes is not
        // proof that the account has no remote document. Never publish over it.
        guard usesIsolatedDirectories || hasGatheredCloudMetadata else { return false }
        for name in [designsFileName, deletedIDsFileName] {
            if let items = metadataQuery?.results as? [NSMetadataItem],
               let item = items.first(where: { ($0.value(forAttribute: NSMetadataItemFSNameKey) as? String) == name }),
               let status = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String,
               status != NSMetadataUbiquitousItemDownloadingStatusCurrent,
               status != NSMetadataUbiquitousItemDownloadingStatusDownloaded { return false }
            let url = directory.appendingPathComponent(name)
            // An iCloud placeholder is not a missing, empty document.
            let placeholder = directory.appendingPathComponent(".\(name).icloud")
            if FileManager.default.fileExists(atPath: placeholder.path) { return false }
            if let status = try? url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]).ubiquitousItemDownloadingStatus,
               status != .current && status != .downloaded { return false }
        }
        return true
    }

    @discardableResult
    private func attemptMergeFromiCloud() -> Bool {
        guard let cloudURL = iCloudFileURL, isRemoteFileReadyForRead() else { return false }
        do {
            let remote = try readFromDisk(at: cloudURL)
            let ids = deletedIDs.union(remote.deletedIDs)
            // Preserve remote data locally before publishing the merged cloud library.
            let local = try writeToDisk(designs + remote.designs, deletedIDs: ids, at: localFileURL)
            let changed = try encoded(designs) != encoded(local.designs) || deletedIDs != local.deletedIDs
            designs = local.designs
            deletedIDs = local.deletedIDs
            let published = try writeToDisk(designs, deletedIDs: deletedIDs, at: cloudURL)
            // Include a concurrent cloud edit encountered inside the write boundary.
            let mirrored = try writeToDisk(published.designs, deletedIDs: published.deletedIDs, at: localFileURL)
            designs = mirrored.designs
            deletedIDs = mirrored.deletedIDs
            lastPersistenceError = nil
            for id in deletedIDs { undoHistoryStore.delete(for: id) }
            return try changed || (encoded(local.designs) != encoded(mirrored.designs))
        } catch {
            reportFailure(error, operation: "iCloud sync could not finish. Saved local designs and undo history are preserved; retry when storage is available.")
            return false
        }
    }

    // MARK: - iCloud Observer

    private func setupiCloudObserver() {
        guard iCloudDocumentsURL != nil else { return }
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K IN %@", NSMetadataItemFSNameKey, [designsFileName, deletedIDsFileName])
        NotificationCenter.default.addObserver(self, selector: #selector(handleMetadataUpdate), name: .NSMetadataQueryDidFinishGathering, object: query)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMetadataUpdate), name: .NSMetadataQueryDidUpdate, object: query)
        metadataQuery = query
        if !query.start() {
            reportFailure(CocoaError(.ubiquitousFileUnavailable), operation: "iCloud discovery could not start. Changes remain saved on this device.")
        }
    }

    @objc private func handleMetadataUpdate(_ notification: Notification) {
        if notification.name == .NSMetadataQueryDidFinishGathering { hasGatheredCloudMetadata = true }
        metadataQuery?.disableUpdates()
        defer { metadataQuery?.enableUpdates() }
        guard isRemoteFileReadyForRead() else {
            requestCloudDownloads()
            return
        }
        if !hasCompletedInitialSync {
            finishInitialSyncIfNeeded()
        } else if attemptMergeFromiCloud() {
            NotificationCenter.default.post(name: .designsDidSync, object: self)
        }
    }

    func merge(local: [Design], remote: [Design]) -> [Design] {
        merged(local: local, remote: remote, deleting: deletedIDs)
    }

    private func merged(local: [Design], remote: [Design], deleting ids: Set<UUID>) -> [Design] {
        var byID: [UUID: Design] = [:]
        for design in local + remote where !ids.contains(design.id) {
            if let existing = byID[design.id], existing.modifiedDate >= design.modifiedDate { continue }
            byID[design.id] = design
        }
        return byID.values.sorted {
            $0.creationDate == $1.creationDate ? $0.id.uuidString < $1.id.uuidString : $0.creationDate < $1.creationDate
        }
    }

    // MARK: - CRUD

    @discardableResult
    func addDesign(_ design: Design) -> Bool {
        guard !deletedIDs.contains(design.id) else {
            reportFailure(CocoaError(.fileNoSuchFile), operation: "This design was deleted. Duplicate it to save a new copy.")
            return false
        }
        var updated = design
        // The legacy ISO-8601 format stores whole seconds. Advance past a known
        // revision so rapid edits (or a clock correction) cannot lose a tie.
        let previous = designs.first(where: { $0.id == design.id })?.modifiedDate ?? .distantPast
        updated.modifiedDate = max(Date(), previous.addingTimeInterval(1))
        guard saveDesigns([updated] + designs.filter { $0.id != design.id }, deleting: deletedIDs) else { return false }
        guard designs.contains(where: { $0.id == design.id }) else {
            reportFailure(CocoaError(.fileNoSuchFile), operation: "This design was deleted on another device. Duplicate it to save a new copy.")
            return false
        }
        return true
    }

    @discardableResult
    func deleteDesign(_ design: Design) -> Bool {
        let saved = saveDesigns(designs.filter { $0.id != design.id }, deleting: deletedIDs.union([design.id]))
        if saved && lastPersistenceError == nil { undoHistoryStore.delete(for: design.id) }
        return saved
    }

    @discardableResult
    func duplicateDesign(_ design: Design) -> Design? {
        var duplicate = design
        duplicate.id = UUID()
        duplicate.creationDate = Date()
        duplicate.modifiedDate = duplicate.creationDate
        return saveDesigns(designs + [duplicate], deleting: deletedIDs) ? duplicate : nil
    }

    func getAllDesigns() -> [Design] { designs }

    func loadDesigns(allowSampleGeneration: Bool = true) -> [Design] {
        do {
            let local = try readFromDisk(at: localFileURL)
            deletedIDs.formUnion(local.deletedIDs)
            designs = merge(local: designs, remote: local.designs)
            if iCloudDocumentsURL != nil {
                if isRemoteFileReadyForRead() { _ = attemptMergeFromiCloud() }
                else { requestCloudDownloads() }
            } else if hasCompletedInitialSync && !local.designFileExists && deletedIDs.isEmpty && designs.isEmpty && allowSampleGeneration {
                // A successfully decoded [] is an intentionally empty library.
                _ = saveDesigns(generateRandomDesigns(count: .random(in: 4...5)), deleting: [])
            } else {
                lastPersistenceError = nil
            }
        } catch {
            reportFailure(error, operation: "Could not read saved designs. No files or undo history were replaced.")
        }
        return designs
    }

    // MARK: - Persistence

    private struct StoredDesigns {
        var designs: [Design]
        var deletedIDs: Set<UUID>
        var designFileExists: Bool
    }

    private func reportFailure(_ error: Error, operation: String) {
        lastPersistenceError = "\(operation) \(error.localizedDescription)"
        NotificationCenter.default.post(name: .designSaveFailed, object: self,
                                        userInfo: [NSLocalizedDescriptionKey: lastPersistenceError!])
    }

    private func encoded<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }

    private func readIfPresent(at url: URL) throws -> Data? {
        do { return try Data(contentsOf: url) }
        catch CocoaError.fileReadNoSuchFile { return nil }
    }

    private func readUncoordinated(designsURL: URL, deletedURL: URL) throws -> StoredDesigns {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = try readIfPresent(at: designsURL)
        let deletionData = try readIfPresent(at: deletedURL)
        return StoredDesigns(designs: try data.map { try decoder.decode([Design].self, from: $0) } ?? [],
                             deletedIDs: try deletionData.map { try decoder.decode(Set<UUID>.self, from: $0) } ?? [],
                             designFileExists: data != nil)
    }

    private func coordinate<T>(at url: URL, _ action: (URL, URL) throws -> T) throws -> T {
        let deletedURL = url.deletingLastPathComponent().appendingPathComponent(deletedIDsFileName)
        let coordinator = NSFileCoordinator()
        var coordinatorError: NSError?
        var result: Result<T, Error>?
        // Both files are read/merged under one claim, including read-only loads.
        coordinator.coordinate(writingItemAt: url, options: .forMerging,
                               writingItemAt: deletedURL, options: .forMerging,
                               error: &coordinatorError) { designsURL, tombstonesURL in
            result = Result { try action(designsURL, tombstonesURL) }
        }
        if let coordinatorError { throw coordinatorError }
        guard let result else { throw CocoaError(.fileReadUnknown) }
        return try result.get()
    }

    private func readFromDisk(at url: URL) throws -> StoredDesigns {
        try coordinate(at: url) { try readUncoordinated(designsURL: $0, deletedURL: $1) }
    }

    /// The original designs.json array stays readable by older installed versions.
    /// Tombstones contain UUIDs only and always win over stale edits from any device.
    private func writeToDisk(_ candidates: [Design], deletedIDs ids: Set<UUID>, at url: URL) throws -> StoredDesigns {
        try coordinate(at: url) { designsURL, deletedURL in
            let disk = try readUncoordinated(designsURL: designsURL, deletedURL: deletedURL)
            let allDeletedIDs = ids.union(disk.deletedIDs)
            let mergedDesigns = merged(local: candidates, remote: disk.designs, deleting: allDeletedIDs)
            let data = try encoded(mergedDesigns)
            let deletionData = try encoded(allDeletedIDs.sorted { $0.uuidString < $1.uuidString })
            // Write deletions first. A failure must never remove an array entry
            // without a durable tombstone; a later array failure is safe to retry.
            if !allDeletedIDs.isEmpty, try readIfPresent(at: deletedURL) != deletionData {
                try deletionData.write(to: deletedURL, options: .atomic)
            }
            if try readIfPresent(at: designsURL) != data {
                try data.write(to: designsURL, options: .atomic)
            }
            return StoredDesigns(designs: mergedDesigns, deletedIDs: allDeletedIDs, designFileExists: true)
        }
    }

    @discardableResult
    private func saveDesigns(_ candidates: [Design], deleting ids: Set<UUID>) -> Bool {
        do {
            let local = try writeToDisk(candidates, deletedIDs: ids, at: localFileURL)
            designs = local.designs
            deletedIDs = local.deletedIDs
            lastPersistenceError = nil
        } catch {
            reportFailure(error, operation: "Could not finish saving this device's designs. Existing design and undo files are preserved; please retry.")
            return false
        }
        if iCloudDocumentsURL != nil {
            if isRemoteFileReadyForRead() { _ = attemptMergeFromiCloud() }
            else {
                reportFailure(CocoaError(.ubiquitousFileUnavailable), operation: "Saved on this device. iCloud is still downloading; changes will merge when it is ready.")
                requestCloudDownloads()
            }
        }
        return true
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
