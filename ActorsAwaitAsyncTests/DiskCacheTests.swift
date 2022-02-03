import XCTest
@testable import ActorsAwaitAsync

class DiskCacheTests: XCTestCase {
    var mockFileManager = MockFileManager()
    var testObject: DiskCacheService!
    let urlRequest = URLRequest(url: URL(string: "http://www.test.com/image.jpg")!)
    let testImage = UIImage()
    var testRealImage: UIImage!
    
    override func setUp() async throws {
        try await super.setUp()
        
        testObject = DiskCacheService(fileManager: mockFileManager)
        
        let imageUrl = Bundle.init(for: ImageLoaderTests.self).url(forResource: "picture1", withExtension: "jpg")
        testRealImage = UIImage(contentsOfFile: imageUrl!.path)
    }
    
    //MARK: cacheImage()
    func test_cacheImage_givenNoDocumentsDirectory_throwError() {
        mockFileManager.documentsDirectoryUrl = nil
        
        XCTAssertThrowsError(try testObject.cacheImage(urlRequest: urlRequest, image: testImage)) { error in
            XCTAssertEqual(error.localizedDescription, DiskCacheService.DiskCacheError.invalidFileURL.localizedDescription)
        }
    }
    
    func test_cacheImage_givenImageWithBadData_throwError() {
        XCTAssertThrowsError(try testObject.cacheImage(urlRequest: urlRequest, image: UIImage())) { error in
            if let diskError = error as? DiskCacheService.DiskCacheError {
            XCTAssertEqual(diskError, DiskCacheService.DiskCacheError.couldNotCreateData)
            } else {
                XCTFail("Should throw DiskCache Error.")
            }
        }
    }
    
    func test_cacheImage_givenFileExists_urlIsValidAndRemoveItemAndCreateFile() throws {
        mockFileManager.fileExistsAtPath = true
        let expectedURL = mockFileManager.documentsDirectoryUrl?.appendingPathComponent("image.jpg")
        
        try testObject.cacheImage(urlRequest: urlRequest, image: testRealImage)
        
        XCTAssertTrue(mockFileManager.didRemoveItemCalled)
        XCTAssertEqual(expectedURL?.path, mockFileManager.capturedFileExistsAtPath)
    }
    
    func test_cacheImage_givenFileDoesntExist_createFile() throws {
        mockFileManager.fileExistsAtPath = false
        let expectedURL = mockFileManager.documentsDirectoryUrl?.appendingPathComponent("image.jpg")
        
        try testObject.cacheImage(urlRequest: urlRequest, image: testRealImage)
        
        XCTAssertFalse(mockFileManager.didRemoveItemCalled)
        XCTAssertEqual(expectedURL?.path, mockFileManager.capturedFileExistsAtPath)
    }
    
    func test_cacheImage_failsToCacheFile() throws {
        mockFileManager.createFileSuccess = false

        XCTAssertThrowsError(try testObject.cacheImage(urlRequest: urlRequest, image: testRealImage)) { error in
            if let diskError = error as? DiskCacheService.DiskCacheError {
            XCTAssertEqual(diskError, DiskCacheService.DiskCacheError.couldNotCacheImage)
            } else {
                XCTFail("Should throw DiskCache Error.")
            }
        }
    }
    
    //MARK: retrieveCachedImage()
    func test_retrieveCachedImage_givenNoDocumentsDirectory_throwError() {
        mockFileManager.documentsDirectoryUrl = nil
        let urlRequest = URLRequest(url: URL(string: "http://www.test.com")!)
        
        XCTAssertThrowsError(try testObject.retrieveCachedImage(urlRequest: urlRequest)) { error in
            if let diskError = error as? DiskCacheService.DiskCacheError {
            XCTAssertEqual(diskError, DiskCacheService.DiskCacheError.invalidFileURL)
            } else {
                XCTFail("Should throw DiskCache Error.")
            }
        }
    }
    
    func test_retrieveCachedImage_givenImageDataReturnedIsNil_throwError() {
        mockFileManager.contentsToReturn = nil
        
        XCTAssertThrowsError(try testObject.retrieveCachedImage(urlRequest: urlRequest)) { error in
            if let diskError = error as? DiskCacheService.DiskCacheError {
            XCTAssertEqual(diskError, DiskCacheService.DiskCacheError.cannotLoadImage)
            } else {
                XCTFail("Should throw DiskCache Error.")
            }
        }
    }
    
    func test_retrieveCachedImage_givenImageDataInWrongFormat_throwError() {
        mockFileManager.contentsToReturn = "Testing".data(using: .utf8)
        
        XCTAssertThrowsError(try testObject.retrieveCachedImage(urlRequest: urlRequest)) { error in
            if let diskError = error as? DiskCacheService.DiskCacheError {
            XCTAssertEqual(diskError, DiskCacheService.DiskCacheError.invalidImageData)
            } else {
                XCTFail("Should throw DiskCache Error.")
            }
        }
    }
}
