import Foundation
import UIKit
import OSLog

actor ImageLoader {
    private enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
    
    private enum ImageLoaderError: Error {
        case noImageFound
        case cannotCreateImage
        case imageNotDownloaded
    }
    
    private var images: [URLRequest: LoaderStatus] = [:]
    private let logger = Logger(subsystem: "com.wwt.actorsawaitasync.imageloader", category: "ImageLoader")
    private let launcher: TaskLaunchable
    
    public init(launcher: TaskLaunchable = TaskLauncher()) {
        self.launcher = launcher
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
                  assertionFailure("Unable to generate a local path for \(urlRequest)")
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
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            throw ImageLoaderError.noImageFound
        }
        
        let data = try Data(contentsOf: url)
        guard let image = UIImage(data: data) else {
            throw ImageLoaderError.cannotCreateImage
        }
        
        logger.debug("Found image for urlRequest \(urlRequest) in the cache.")
        images[urlRequest] = .fetched(image)
        return image
    }
    
    private func fileName(for urlRequest: URLRequest) -> URL? {
        guard let fileName = urlRequest.url?.relativePath.dropFirst().addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let applicationSupport = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                  return nil
              }
        
        return applicationSupport.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "-"))
    }
}
