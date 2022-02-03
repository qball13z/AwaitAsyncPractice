import XCTest
@testable import ActorsAwaitAsync

class MockDiskCache: DiskCacheProtocol {
    var retrieveCachedImageWasCalled = false
    var retrieveCachedImageCapturedUrlRequest: URLRequest?
    var retrieveCachedImageReturnImageValue = UIImage()
    var retrieveCachedImageShouldReturnImage = true
    var retrieveCachedImageErrorShouldThrow: Error?
    
    var cacheImageWasCalled = false
    var cacheImageCapturedUrlRequest: URLRequest?
    var cacheImageCapturedImage: UIImage?
    
    
    func cacheImage(urlRequest: URLRequest, image: UIImage) throws {
        cacheImageWasCalled = true
        cacheImageCapturedImage = image
        cacheImageCapturedUrlRequest = urlRequest
    }
    
    func retrieveCachedImage(urlRequest: URLRequest) throws -> UIImage {
        retrieveCachedImageWasCalled = true
        retrieveCachedImageCapturedUrlRequest = urlRequest
        
        if let diskCacheError = retrieveCachedImageErrorShouldThrow {
            throw diskCacheError
        }
        
        return retrieveCachedImageReturnImageValue
    }
}
