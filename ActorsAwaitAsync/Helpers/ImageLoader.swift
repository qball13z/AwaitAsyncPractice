import Foundation
import UIKit

actor ImageLoader {
    private var images: [URLRequest: LoaderStatus] = [:]
    
    public func fetch(_ url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        return try await fetch(request)
    }
    
    public func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        if let status = images[urlRequest] {
            switch status {
            case .fetched(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        do {
            let image = try self.imageFromFileSystem(for: urlRequest)
            images[urlRequest] = .fetched(image)
            return image
        } catch {
            let task: Task<UIImage, Error> = Task {
                let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
                let image = UIImage(data: imageData)!
                try self.persistImage(image, for: urlRequest)
                return image
            }
            
            images[urlRequest] = .inProgress(task)
            let image = try await task.value
            images[urlRequest] = .fetched(image)
            return image
        }
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
    
    private func imageFromFileSystem(for urlRequest: URLRequest) throws -> UIImage {
        guard let url = fileName(for: urlRequest) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            throw ImageLoaderError.noImageFound
        }
        
        let data = try Data(contentsOf: url)
        guard let image = UIImage(data: data) else {
            throw ImageLoaderError.cannotCreateImage
        }
        
        return image
    }
    
    private func fileName(for urlRequest: URLRequest) -> URL? {
        guard let fileName = urlRequest.url?.relativePath.dropFirst().addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let applicationSupport = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                  return nil
              }
        
        return applicationSupport.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "-"))
    }
    
    private enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
    
    private enum ImageLoaderError: Error {
        case noImageFound
        case cannotCreateImage
    }
}
