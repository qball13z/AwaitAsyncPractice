import XCTest
@testable import ActorsAwaitAsync

class MockDiskCacheService: DiskCacheServiceProtocol {
    var retrieveCachedImageWasCalled = false
    var retrieveCachedImageCapturedUrlRequest: URLRequest?
    var retrieveCachedImageReturnImageValue = UIImage()
    var retrieveCachedImageShouldReturnImage = true
    var retrieveCachedImageErrorShouldThrow: Error?
    
    var cacheImageWasCalled = false
    var cacheImageCapturedUrlRequest: URLRequest?
    var cacheImageCapturedImage: UIImage?
    var cacheImageShouldNotThrow = true
    
    
    func cacheImage(urlRequest: URLRequest, image: UIImage) throws {
        cacheImageWasCalled = true
        cacheImageCapturedImage = image
        cacheImageCapturedUrlRequest = urlRequest
        
        if !cacheImageShouldNotThrow {
            throw DiskCacheService.DiskCacheError.couldNotCreateData
        }
    }
    
    func retrieveCachedImage(urlRequest: URLRequest) throws -> UIImage {
        retrieveCachedImageWasCalled = true
        retrieveCachedImageCapturedUrlRequest = urlRequest
        
        if !retrieveCachedImageShouldReturnImage {
            throw DiskCacheService.DiskCacheError.invalidImageData
        }
        
        return retrieveCachedImageReturnImageValue
    }
}
