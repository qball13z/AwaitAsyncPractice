import Foundation
import UIKit
import OSLog

actor ImageCache {
    public enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
    
    public var images: [URLRequest: LoaderStatus] = [:]
    private let logger = Logger(subsystem: "com.wwt.actorsawaitasync.imageloader", category: "ImageLoader")
    private let launcher: TaskLaunchable
    private var diskCache: DiskCacheProtocol
    
    public init(launcher: TaskLaunchable = TaskLauncher(), diskCache: DiskCacheProtocol = DiskCache()) {
        self.launcher = launcher
        self.diskCache = diskCache
    }
    
    public func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        do {
            return try await getImageFromURLRequest(urlRequest)
        } catch {
            logger.error("Error: \(error.localizedDescription)")
        }
        
        // Recognize that we had an error for tests at this point
        let task: Task<UIImage, Error> = launcher.imageTask(priority: nil) { [weak self] in
            self?.logger.debug("Starting Download with URLRequest: \(urlRequest)")
            let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
            let image = UIImage(data: imageData)!
            try await self?.diskCache.cacheImage(urlRequest: urlRequest, image: image)
            return image
        }
        
        images[urlRequest] = .inProgress(task)
        let image = try await task.value
        logger.debug("Completed with URLRequest: \(urlRequest)")
        images[urlRequest] = .fetched(image)
        return image
    }
    
    private func getImageFromURLRequest(_ urlRequest: URLRequest) async throws -> UIImage {
        if let status = images[urlRequest] {
            switch status {
            case .fetched(let image):
                logger.debug("Fetched image \(image) with URLRequest \(urlRequest)")
                return image
            case .inProgress(let task):
                logger.debug("In Progress task with URLRequest \(urlRequest)")
                return try await task.value
            }
        }
        
        let image = try diskCache.retrieveCachedImage(urlRequest: urlRequest)
        images[urlRequest] = .fetched(image)
        return image
    }
}
