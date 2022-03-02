import UIKit
@testable import ActorsAwaitAsync

// How hard is it to use a mock of an actor that is an @actor?

// What are the ramifications of using a class vs actor in a mock?
// If the protocol is an actor you must conform to that type with your mock as well.

//
actor MockImageCacheService: ImageCacheServiceProtocol {
    var fetchCapturedURLRequest: URLRequest?
    var fetchReturnImageValue = UIImage()
    var fetchShouldReturnImage = true
    
    var getImageFromURLRequestCapturedURLRequest: URLRequest?
    var getImageFromURLRequestReturnImageValue = UIImage()
    var getImageFromURLRequestShouldReturnImage = true
    
    public var images: [URLRequest: LoaderStatus] = [:]
    private let launcher: TaskLaunchable
    private var diskCache: DiskCacheServiceProtocol
    
    public func setShouldFetchReturnImage(_ shouldSet: Bool) async {
        fetchShouldReturnImage = shouldSet
    }
    
    public func configureMock(fetchCapturedURLRequest: URLRequest? = nil,
                              fetchReturnImageValue: UIImage = UIImage(),
                              fetchShouldReturnImage: Bool = true,
                              getImageFromURLRequestCapturedURLRequest: URLRequest? = nil,
                              getImageFromURLRequestReturnImageValue: UIImage = UIImage(),
                              getImageFromURLRequestShouldReturnImage: Bool = true) {
        self.fetchCapturedURLRequest = fetchCapturedURLRequest
        self.fetchReturnImageValue = fetchReturnImageValue
        self.fetchShouldReturnImage = fetchShouldReturnImage
        self.getImageFromURLRequestCapturedURLRequest = getImageFromURLRequestCapturedURLRequest
        self.getImageFromURLRequestReturnImageValue = getImageFromURLRequestReturnImageValue
        self.getImageFromURLRequestShouldReturnImage = getImageFromURLRequestShouldReturnImage
    }
    
    enum MockImageCacheServiceError: Error {
        case fetchError
        case getImageFromURLRequestError
    }
    
    public init(launcher: TaskLaunchable = TaskLauncherService(), diskCache: DiskCacheServiceProtocol = DiskCacheService()) {
        self.launcher = launcher
        self.diskCache = diskCache
    }
    
    func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        fetchCapturedURLRequest = urlRequest
        
        if !fetchShouldReturnImage {
            throw MockImageCacheServiceError.fetchError
        }
        
        return fetchReturnImageValue
    }
    
    func getImageFromURLRequest(_ urlRequest: URLRequest) async throws -> UIImage {
        getImageFromURLRequestCapturedURLRequest = urlRequest
        
        if !getImageFromURLRequestShouldReturnImage {
            throw MockImageCacheServiceError.getImageFromURLRequestError
        }
        
        return getImageFromURLRequestReturnImageValue
    }
}
