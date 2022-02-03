import XCTest
@testable import ActorsAwaitAsync

class DiskCacheTests: XCTestCase {
    var mockFileManager = MockFileManager()
    var testObject: DiskCache!
    
    override func setUp() async throws {
        try await super.setUp()
        
        testObject = DiskCache(fileManager: mockFileManager)
    }
    
    //MARK: cacheImage()
    func test_cacheImage_givenNoDocumentsDirectory_throwError() {
        mockFileManager.documentsDirectoryUrl = nil
        let urlRequest = URLRequest(url: URL(string: "http://www.test.com")!)
        let testImage = UIImage()
        
        XCTAssertThrowsError(try testObject.cacheImage(urlRequest: urlRequest, image: testImage)) { error in
            XCTAssertEqual(error.localizedDescription, DiskCache.DiskCacheError.invalidFileURL.localizedDescription)
        }
    }
    
//    func test_cacheImage_give
    
    //MARK: retrieveCachedImage()
    func test_retrieveCachedImage_givenNoDocumentsDirectory_throwError() {
        mockFileManager.documentsDirectoryUrl = nil
        let urlRequest = URLRequest(url: URL(string: "http://www.test.com")!)
        
        XCTAssertThrowsError(try testObject.retrieveCachedImage(urlRequest: urlRequest)) { error in
            XCTAssertEqual(error.localizedDescription, DiskCache.DiskCacheError.invalidFileURL.localizedDescription)
        }
    }

}
