import UIKit
@testable import ActorsAwaitAsync

class MockImageCacheService: ImageCacheServiceProtocol {
    func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        return UIImage()
    }
    
    func getImageFromURLRequest(_ urlRequest: URLRequest) async throws -> UIImage {
        return UIImage()
    }
}
