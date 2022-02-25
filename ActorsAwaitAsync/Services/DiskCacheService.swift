import UIKit
import OSLog

protocol FileManagerProtocol {
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func contents(atPath: String) -> Data?
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool
    func fileExists(atPath: String) -> Bool
    func removeItem(at URL: URL) throws 
}

extension FileManager: FileManagerProtocol {}

protocol DiskCacheServiceProtocol {
    func cacheImage(urlRequest: URLRequest, image: UIImage) throws
    func retrieveCachedImage(urlRequest: URLRequest) throws -> UIImage
}

class DiskCacheService: DiskCacheServiceProtocol {
    enum DiskCacheError: Error {
        case invalidFileURL
        case cannotLoadImage
        case invalidImageData
        case couldNotCreateData
        case couldNotCacheImage
    }
    
    private let fileManager: FileManagerProtocol
    private var documentsDirectory: URL?
    private let logger = Logger(subsystem: "com.wwt.actorsawaitasync.diskCache", category: "DiskCache")
    
    public init(fileManager: FileManagerProtocol = FileManager.default) {
        self.fileManager = fileManager
    }
    
    func cacheImage(urlRequest: URLRequest, image: UIImage) throws {
        let url = try fileName(for: urlRequest)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw DiskCacheError.couldNotCreateData
        }
        try storeFileAt(url: url, data: data)
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
              let applicationSupport = documentsDirectory,
                !fileName.isEmpty else {
                  throw DiskCacheError.invalidFileURL
              }
        //TODO: Test this line
        return applicationSupport.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "-"))
    }
    
    private func storeFileAt(url: URL!, data: Data) throws {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        
        if !fileManager.createFile(atPath: url.path, contents: data, attributes: nil) {
            throw DiskCacheError.couldNotCacheImage
        }
    }
}
