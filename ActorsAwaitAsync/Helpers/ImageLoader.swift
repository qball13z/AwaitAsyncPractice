import Foundation
import UIKit
import OSLog

protocol FileManagerProtocol {
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func contents(atPath: String) -> Data?
}

actor ImageLoader {
    public enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
    
    enum ImageLoaderError: Error {
        case noImageFound
        case cannotCreateImage
        case imageNotDownloaded
        case cannotGetImage
        case cannotSaveImage
        case unableToGenerateLocalPath
    }
    
    private let fileManager: FileManagerProtocol
    public var images: [URLRequest: LoaderStatus] = [:]
    private let logger = Logger(subsystem: "com.wwt.actorsawaitasync.imageloader", category: "ImageLoader")
    private let launcher: TaskLaunchable
    
    public init(launcher: TaskLaunchable = TaskLauncher(), fileManager: FileManagerProtocol = FileManager.default) {
        self.launcher = launcher
        self.fileManager = fileManager
    }
    
    
    public func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        do {
            return try await getImageFromURLRequest(urlRequest)
        } catch {
            logger.error("Error: \(error.localizedDescription)")
        }
        
        let task: Task<UIImage, Error> = launcher.imageTask(priority: nil) {
            self.logger.debug("Starting Download with URLRequest: \(urlRequest)")
            let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
            let image = UIImage(data: imageData)!
            try await self.persistImage(image, for: urlRequest)
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
        return try loadImageFromFileSystem(for: urlRequest)
    }
    
    private func persistImage(_ image: UIImage, for urlRequest: URLRequest) throws {
        guard let url = fileName(for: urlRequest),
              let data = image.jpegData(compressionQuality: 0.8) else {
//                  assertionFailure("Unable to generate a local path for \(urlRequest)")
                  return
              }
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            print(error)
        }
    }
    
    private func loadImageFromFileSystem(for urlRequest: URLRequest) throws -> UIImage {
        guard let url = fileName(for: urlRequest) else {
            throw ImageLoaderError.unableToGenerateLocalPath
        }
        
        guard let data = fileManager.contents(atPath: url.path) else {
            throw ImageLoaderError.cannotSaveImage
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageLoaderError.cannotCreateImage
        }
        
        logger.debug("Found image for urlRequest \(urlRequest) in the cache.")
        images[urlRequest] = .fetched(image)
        return image
    }
    
    private func fileName(for urlRequest: URLRequest) -> URL? {
        guard let fileName = urlRequest.url?.relativePath.dropFirst().addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let applicationSupport = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                  return nil
              }
        
        return applicationSupport.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "-"))
    }
}

extension FileManager: FileManagerProtocol {}
