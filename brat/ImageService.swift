import UIKit

class ImageService {
    private let cacheQueue = DispatchQueue(label: "com.pictureGrid.imageCacheQueue", attributes: .concurrent)
    private let diskManagementQueue = DispatchQueue(label: "com.pictureGrid.diskManagementQueue")
    
    private var memoryCache = NSCache<NSString, UIImage>()
    private var ongoingRequests: [AnyHashable: [String: URLSessionDownloadTask]] = [:]
    private var requestContexts: [String: AnyHashable] = [:]
    private var currentDiskCacheSize: UInt64 = 0
    private let maxDiskCacheSize: UInt64 = 1024 * 1024 * 1024 // 1 GB
    private var lastCacheManagementDate = Date.distantPast
    
    private var isUnderMemoryPressure = false
    private let useDecompression = false
    
    init() {
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(memoryPressureDetected),
                                               name: UIApplication.didReceiveMemoryWarningNotification, 
                                               object: nil)
        memoryCache.totalCostLimit = Int(maxDiskCacheSize) // Set an approximate cost limit
    }
    
    deinit {
        print("File: \((#file as NSString).lastPathComponent), Function: \(#function)")
    }
    
    func fetchImage(of size: ImageURLs.Size,
                    from imageURLs: ImageURLs,
                    context: AnyHashable? = nil,
                    validation: @escaping ()->String?,
                    completion: @escaping (UIImage, String)->Void) {
        if let targetURL = imageURLs.closestSize(to: size),
           let existingImage = memoryCache.object(forKey: targetURL.key as NSString),
           imageURLs.contains(validation()) {
            completion(existingImage, targetURL)
            return
        }
        
        if let targetURL = imageURLs.closestSize(to: size),
           fileExists(for: targetURL),
           // should move to background queue:
           let existingImage = loadImageFromDisk(with: targetURL),
           imageURLs.contains(validation()) {
            completion(existingImage, targetURL)
            memoryCache.setObject(existingImage,
                                  forKey: targetURL.key as NSString)
            return
        }
        
        var possibleURLs = imageURLs.sizesToTry(to: size)
        guard possibleURLs.first != nil else {
            return
        }
        
        let targetURL = possibleURLs.removeFirst()
        
        for url in possibleURLs {
            if let existingImage = memoryCache.object(forKey: url.key as NSString),
               imageURLs.contains(validation()) {
                completion(existingImage, url)
                break
            }
            
            if fileExists(for: url),
               let existingImage = loadImageFromDisk(with: url),
               imageURLs.contains(validation()) {
                completion(existingImage, url)
                memoryCache.setObject(existingImage,
                                      forKey: url.key as NSString)
                break
            }
        }
        
        fetchImage(targetURL,
                   context: context) { result in
            switch result {
            case .success(let image, let url):
                guard imageURLs.contains(validation()) else {
                    return
                }
                completion(image, url)
            case .failure(_, _):
                break
            }
        }
    }
    
    func fetchImage(_ imageURLString: String,
                    context: AnyHashable?,
                    priority: ImageFetchPriority = .medium,
                    retryCount: Int = 3,
                    compressionQuality: CGFloat = 0.7,
                    completion: @escaping (ImageFetchResult) -> Void) {
        cacheQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            // Contextual key to differentiate between different usages of the same image URL
            let contextualKey = (context != nil) ? "\(context!):\(imageURLString.key)" : imageURLString.key
            
            // Check memory cache
            if let cachedImage = memoryCache.object(forKey: contextualKey as NSString) {
                DispatchQueue.main.async {
                    completion(.success(image: cachedImage,
                                        url: imageURLString))
                }
                return
            }
            
            // Check disk cache
            if let image = loadImageFromDisk(with: imageURLString) {
                // Image exists on disk, return it and add to memory cache
                memoryCache.setObject(image, forKey: contextualKey as NSString)
                completion(.success(image: image, url: imageURLString))
                return
            }
            
            // Check if a request is already ongoing for the same URL and context
            if let tasks = ongoingRequests[context ?? AnyHashable("global")],
               let task = tasks[imageURLString],
               task.priority < priority.urlSessionTaskPriority {
                task.priority = priority.urlSessionTaskPriority
                return
            }
            
            // No valid cache found, initiate fetch
            fetchFromNetwork(imageURLString,
                             context: context ?? AnyHashable("global"),
                             priority: priority,
                             retryCount: retryCount) { result in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    switch result {
                    case .success(let image, let url):
                        addImageToMemoryCache(image, forKey: contextualKey)
                        completion(.success(image: image, url: url))
                    case .failure(let error, let url):
                        completion(.failure(error: error, url: url))
                    }
                }
            }
        }
    }
    
    private func fetchFromNetwork(_ imageURLString: String,
                                  context: AnyHashable,
                                  priority: ImageFetchPriority,
                                  retryCount: Int,
                                  compressionQuality: CGFloat = 0.7,
                                  completion: @escaping (ImageFetchResult) -> Void,
                                  currentRetry: Int = 0) {
        guard let url = URL(string: imageURLString) else {
            completion(.failure(error: imageServiceError("Invalid URL from: \(imageURLString)"),
                                url: imageURLString))
            return
        }
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] location, response, error in
            guard let self = self else {
                return
            }
            
            if let location = location, error == nil {
                // Move the downloaded file from the temp location to the cache directory
                let targetPath = getFilePath(forImageName: imageName(fromURL: imageURLString))
                try? FileManager.default.moveItem(at: location,
                                                  to: targetPath)
                
                // Load the image from the disk
                if let image = UIImage(contentsOfFile: targetPath.path) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {
                            return
                        }
                        saveImageToDisk(image,
                                        addToInMemoryCache: true,
                                        withName: imageURLString,
                                        compressionQuality: 0.7)
                        completion(.success(image: image,
                                            url: imageURLString))
                    }
                } else {
                    completion(.failure(error: imageServiceError("Could not load image from disk"),
                                        url: imageURLString))
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error: error, url: imageURLString))
                }
            }
        }
        
        downloadTask.priority = priority.urlSessionTaskPriority
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self else {
                return
            }
            ongoingRequests[context]?[imageURLString] = downloadTask
        }
        downloadTask.resume()
    }
    
    private func handleDownloadTaskResponse(location: URL?,
                                            response: URLResponse?,
                                            error: Error?,
                                            imageURLString: String,
                                            context: AnyHashable,
                                            priority: ImageFetchPriority,
                                            retryCount: Int,
                                            currentRetry: Int,
                                            compressionQuality: CGFloat,
                                            completion: @escaping (ImageFetchResult) -> Void) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self else {
                return
            }
            ongoingRequests.removeValue(forKey: imageURLString)
        }
        
        if let error = error {
            // Handle retries for server errors
            if let httpResponse = response as? HTTPURLResponse, [500, 502, 503, 504].contains(httpResponse.statusCode), currentRetry < retryCount {
                let retryDelay = pow(2.0, Double(currentRetry)) // Exponential backoff
                DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                    guard let self else {
                        return
                    }
                    fetchFromNetwork(imageURLString,
                                     context: context,
                                     priority: priority,
                                     retryCount: retryCount,
                                     compressionQuality: compressionQuality,
                                     completion: completion,
                                     currentRetry: currentRetry + 1)
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(error: error, url: imageURLString))
                }
            }
            return
        }
        
        guard let location = location else {
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                completion(.failure(error: imageServiceError("Missing download location",
                                                             code: #line),
                                    url: imageURLString))
            }
            return
        }
        
        let targetPath = getFilePath(forImageName: imageName(fromURL: imageURLString))
        do {
            try FileManager.default.moveItem(at: location, to: targetPath)
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self,
                        let image = UIImage(contentsOfFile: targetPath.path) else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {
                            return
                        }
                        completion(.failure(error: imageServiceError("Could not load image from disk",
                                                                     code: #line), url
                                            : imageURLString))
                    }
                    return
                }
                
                let processedImage: UIImage = priority > .prefetch ? decompressImage(image) : image
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    addImageToMemoryCache(processedImage,
                                          forKey: imageURLString)
                    saveImageToDisk(processedImage,
                                    withName: imageName(fromURL: imageURLString),
                                    compressionQuality: compressionQuality)
                    completion(.success(image: processedImage,
                                        url: imageURLString))
                }
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                completion(.failure(error: imageServiceError("Failed to move downloaded file",
                                                             code: #line),
                                    url: imageURLString))
            }
        }
    }
    
    private func handleDataTaskResponse(data: Data?,
                                        error: Error?,
                                        response: URLResponse?,
                                        imageURLString: String,
                                        context: AnyHashable,
                                        priority: ImageFetchPriority,
                                        retryCount: Int,
                                        currentRetry: Int,
                                        compressionQuality: CGFloat,
                                        completion: @escaping (ImageFetchResult) -> Void) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self else {
                return
            }
            ongoingRequests.removeValue(forKey: imageURLString)
        }
        
        if let httpResponse = response as? HTTPURLResponse,
           [500, 502, 503, 504].contains(httpResponse.statusCode),
           currentRetry < retryCount {
            // Retry with exponential backoff
            let retryDelay = pow(2.0, Double(currentRetry)) // Exponential backoff
            DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                guard let self else {
                    return
                }
                fetchFromNetwork(imageURLString,
                                 context: context,
                                 priority: priority,
                                 retryCount: retryCount,
                                 compressionQuality: compressionQuality,
                                 completion: completion,
                                 currentRetry: currentRetry + 1)
            }
        } else if let data,
                  let downloadedImage = UIImage(data: data) {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self else {
                    return
                }
                
                let processedImage: UIImage = { [weak self] in
                    guard let self,
                          priority > .prefetch else {
                        return downloadedImage
                    }
                    return decompressImage(downloadedImage)
                }()
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    addImageToMemoryCache(processedImage,
                                          forKey: imageURLString)
                    saveImageToDisk(processedImage,
                                    withName: imageName(fromURL: imageURLString),
                                    compressionQuality: compressionQuality)
                    completion(.success(image: processedImage,
                                        url: imageURLString))
                }
            }
        } else {
            let finalError = error ?? imageServiceError("Failed to download image",
                                                        code: #line)
            DispatchQueue.main.async {
                completion(.failure(error: finalError,
                                    url: imageURLString))
            }
        }
    }
    
    private func decompressImage(_ image: UIImage) -> UIImage {
        guard useDecompression else {
            return image
        }
        
        if isUnderMemoryPressure {
            return image
        }
        
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.opaque = true
        let renderer = UIGraphicsImageRenderer(size: image.size, format: rendererFormat)
        
        let decompressedImage = renderer.image { context in
            image.draw(at: .zero)
        }
        return decompressedImage
    }
    
    // Cancel ongoing fetches for a given context
    func cancelFetching(for context: AnyHashable?,
                        clearCache: Bool) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            if let context = context {
                ongoingRequests[context]?.forEach { $1.cancel() }
                if clearCache {
                    let contextRequests = requestContexts.filter { $1 == context }
                    for (url, _) in contextRequests {
                        memoryCache.removeObject(forKey: url as NSString)
                    }
                }
                ongoingRequests.removeValue(forKey: context)
            } else {
                ongoingRequests.forEach { $0.value.forEach { $1.cancel() } }
                ongoingRequests.removeAll()
                if clearCache {
                    memoryCache.removeAllObjects()
                }
            }
        }
    }
    
    // Clear in-memory cache
    func clearInMemoryCache() {
        cacheQueue.async(flags: .barrier) { [weak self] in
            self?.memoryCache.removeAllObjects()
        }
    }
    
    // Reduce the size of the disk cache
    func reduceDiskCache(to megabytes: Int) {
        let targetSize = UInt64(megabytes) * 1024 * 1024 // Convert megabytes to bytes
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }
            let cacheDirectory = getCacheDirectory()
            let fileManager = FileManager.default
            
            // Attempt to get the directory contents
            guard let fileURLs = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles) else { return }
            
            // Map files to their sizes and sort by file size in descending order
            let files = fileURLs.compactMap { url -> (URL, UInt64)? in
                guard let fileSize = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else { return nil }
                return (url, UInt64(fileSize))
            }.sorted { $0.1 > $1.1 }
            
            var accumulatedSize: UInt64 = 0
            
            // Iterate through files, removing them until the target size is met
            for file in files {
                accumulatedSize += file.1
                if accumulatedSize > targetSize {
                    do {
                        try fileManager.removeItem(at: file.0)
                        currentDiskCacheSize -= file.1
                        if currentDiskCacheSize <= targetSize {
                            break
                        }
                    } catch {
                        print("Failed to remove item: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @objc private func memoryPressureDetected() {
        isUnderMemoryPressure = true
        clearInMemoryCache() // Optional: clear cache under memory pressure
    }
    
    private func imageServiceError(_ description: String,
                                   code codeLine: Int = #line,
                                   file: String = #file,
                                   function: String = #function) -> NSError {
        let fileName = (file as NSString).lastPathComponent
        let userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: description,
            "file": fileName,
            "function": function,
            "line": codeLine
        ]
        return NSError(domain: "ImageServiceError",
                       code: -codeLine,
                       userInfo: userInfo)
    }
    
    
    
    func saveImageToDisk(_ image: UIImage,
                         addToInMemoryCache: Bool = false,
                         withName name: String,
                         compressionQuality: CGFloat) {
        defer {
            if addToInMemoryCache {
                memoryCache.setObject(image,
                                      forKey: name.key as NSString)
            }
        }
        guard let data = image.jpegData(compressionQuality: compressionQuality) ?? image.pngData() else {
            return
        }
        let filePath = getFilePath(forImageName: name)
        
        do {
            try data.write(to: filePath, options: .atomic)
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath.path)
            let fileSize = attributes[FileAttributeKey.size] as? UInt64 ?? 0
            
            cacheQueue.async(flags: .barrier) { [weak self] in
                guard let self else {
                    return
                }
                currentDiskCacheSize += fileSize
                manageDiskCache()
            }
        } catch {
            print("Error saving file to disk: \(error.localizedDescription)")
        }
        
        assert(fileExists(for: name))
    }
    
    private func loadImageFromDisk(with name: String?) -> UIImage? {
        guard let imageName = name?.key else {
            return nil
        }
        
        let filePath: String? = {
#if targetEnvironment(macCatalyst)
            if #available(macCatalyst 16.0, *) {
                return getFilePath(forImageName: imageName).path()
            }
#else
            if #available(iOS 16.0, *) {
                return getFilePath(forImageName: imageName).path()
            }
#endif
            
            let filePath = getFilePath(forImageName: imageName).path
            guard !filePath.isEmpty else {
                return nil
            }
            return filePath
        }()
        guard let filePath,
              fileExists(at: filePath),
              let image = UIImage(contentsOfFile: filePath) else {
            return nil
        }
        
        // Update file's modification date to support LRU eviction
        let modificationDate = [FileAttributeKey.modificationDate: Date()]
        try? FileManager.default.setAttributes(modificationDate,
                                               ofItemAtPath: filePath)
        
        return image
    }
    
    private func fileExists(for name: String?) -> Bool {
        guard let imageName = name?.key else {
            return false
        }
        
        let filePath = getFilePath(forImageName: imageName).path
        
        return fileExists(at: filePath)
    }
    
    private func fileExists(at filePath: String) -> Bool {
        guard FileManager.default.fileExists(atPath: filePath) else {
            return false
        }
        return true
    }
    
    private func imageExsist(with name: String?) -> Bool {
        guard let name = name?.key else {
            return false
        }
        let filePath = getFilePath(forImageName: name).path
        
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    func manageDiskCache() {
        let now = Date()
        guard lastCacheManagementDate.addingTimeInterval(5) < now else {
            return
        }
        
        diskManagementQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            lastCacheManagementDate = now
            performDiskCacheManagement()
        }
    }
    
    private func performDiskCacheManagement() {
        let fileManager = FileManager.default
        let cacheDirectory = getCacheDirectory()
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            
            let filesAttributes = fileURLs.map { url -> (URL, UInt64, Date) in
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let size = attributes?[.size] as? UInt64 ?? 0
                let modificationDate = attributes?[.modificationDate] as? Date ?? Date.distantPast
                return (url, size, modificationDate)
            }
            
            let sortedFiles = filesAttributes.sorted { $0.2 < $1.2 } // Sort by modification date for LRU
            
            for (url, size, _) in sortedFiles {
                guard currentDiskCacheSize > maxDiskCacheSize else { break }
                try fileManager.removeItem(at: url)
                currentDiskCacheSize -= size
            }
        } catch {
            print("Error managing disk cache: \(error.localizedDescription)")
        }
    }
    
    private func getCacheDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        return cacheDirectory
    }
    
    private func getFilePath(forImageName name: String) -> URL {
        return getCacheDirectory().appendingPathComponent(name.key)
    }
    
    private func imageName(fromURL urlString: String) -> String {
        return urlString.components(separatedBy: "/").last ?? urlString.hashValue.description
    }
    
    func addImageToMemoryCache(_ image: UIImage?,
                               forKey key: String) {
        guard let image else {
            return
        }
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self else {
                return
            }
            memoryCache.setObject(image, forKey: key.key as NSString)
        }
    }
    
    func prefetch(_ imageURLStrings: [String], context: AnyHashable?) {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            for imageURLString in imageURLStrings {
                // Check memory cache first
                if memoryCache.object(forKey: imageURLString as NSString) != nil {
                    continue // Image is already in memory, no need to prefetch
                }
                
                // Check disk cache next
                let imageName = imageName(fromURL: imageURLString)
                if imageExsist(with: imageName) {
                    continue // Image is already on disk, no need to prefetch
                }
                
                // Fetch from network at low priority
                fetchImage(imageURLString,
                           context: context,
                           priority: .low,
                           retryCount: 1,
                           completion: { _ in
                    
                })
            }
        }
    }
}

extension String {
    var key: String {
        return sanitizedForFilename()
    }
    
    func sanitizedForFilename() -> String {
        // Define a dictionary of characters to replace
        let replacements: [Character: Character] = [
            "/": "s", // Replace slashes
            "?": "q", // Replace question marks
            "&": "a", // Replace ampersands
            "%": "p", // Replace percent symbols
            ":": "c", // Replace colons
            "#": "h"  // Replace hash
        ]
        
        return map { replacements[$0] ?? $0 }.reduce("") { $0 + String($1) }
    }
    
}
