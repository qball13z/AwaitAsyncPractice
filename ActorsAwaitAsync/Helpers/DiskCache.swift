import Foundation

protocol FileManagerProtocol {
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func contents(atPath: String) -> Data?
}

extension FileManager: FileManagerProtocol {}

class DiskCache {
    
    private let fileManager: FileManagerProtocol
    
    public init(fileMangager: FileManagerProtocol = FileManager.default) {
        self.fileManager = fileMangager
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
        if documentsDirectory == nil {
            documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        }
        
        guard let fileName = urlRequest.url?.relativePath.dropFirst().addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let applicationSupport = documentsDirectory else {
                  return nil
              }
        
        return applicationSupport.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "-"))
    }
    
    
}
