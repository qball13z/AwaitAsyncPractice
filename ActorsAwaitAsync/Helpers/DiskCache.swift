import UIKit
import OSLog

protocol FileManagerProtocol {
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func contents(atPath: String) -> Data?
}

extension FileManager: FileManagerProtocol {}

protocol DiskCacheProtocol {
    func cacheImage(urlRequest: URLRequest, image: UIImage) throws
    func retrieveCachedImage(urlRequest: URLRequest) throws -> UIImage
}

class DiskCache: DiskCacheProtocol {
    enum DiskCacheError: Error {
        case invalidFileURL
        case cannotLoadImage
        case invalidImageData
        case couldNotCreateData
    }
    
    private let fileManager: FileManagerProtocol
    private var documentsDirectory: URL?
    private let logger = Logger(subsystem: "com.wwt.actorsawaitasync.diskCache", category: "DiskCache")
    
    public init(fileMangager: FileManagerProtocol = FileManager.default) {
        self.fileManager = fileMangager
    }
    
    func cacheImage(urlRequest: URLRequest, image: UIImage) throws {
        let url = try fileName(for: urlRequest)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw DiskCacheError.couldNotCreateData
        }
        try data.write(to: url, options: .atomic)
    }
    
    func retrieveCachedImage(urlRequest: URLRequest) throws -> UIImage {
        let url = try fileName(for: urlRequest)
        
        guard let data = fileManager.contents(atPath: url.path) else {
            throw DiskCacheError.cannotLoadImage
        }
        
        guard let image = UIImage(data: data) else {
            throw DiskCacheError.invalidImageData
        }
        return image
    }
    
    private func fileName(for urlRequest: URLRequest) throws -> URL {
        if documentsDirectory == nil {
            documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        }
        
        guard let fileName = urlRequest.url?.relativePath.dropFirst().addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let applicationSupport = documentsDirectory else {
                  throw DiskCacheError.invalidFileURL
              }
        
        return applicationSupport.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "-"))
    }
}
