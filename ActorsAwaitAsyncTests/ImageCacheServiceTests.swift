import XCTest
@testable import ActorsAwaitAsync

// Do we need this?
class MockTaskLauncher: TaskLaunchable {
    var tasks = [Task<UIImage, Error>]()
    var shouldSuspendFirstTask = false
    var suspendingImageFunction: @Sendable () async throws -> UIImage = {
        sleep(10)
        return UIImage()
    }

    func imageTask(priority: TaskPriority?, operation: @escaping @Sendable () async throws -> UIImage) -> Task<UIImage, Error> {
        let task: Task<UIImage, Error>

        if tasks.isEmpty && shouldSuspendFirstTask {
            task = Task(priority: priority, operation: suspendingImageFunction)
        } else {
            task = Task(priority: priority, operation: operation)
        }
        tasks.append(task)

        return task
    }
}

class ImageCacheServiceTests: XCTestCase {
    let mockTaskLauncher = MockTaskLauncher()
    let mockDiskCache = MockDiskCacheService()
    var testObject = ImageCacheService()
    let imageOne = Bundle.init(for: ImageCacheServiceTests.self).url(forResource: "picture1", withExtension: "jpg")
    let imageTwo = Bundle.init(for: ImageCacheServiceTests.self).url(forResource: "picture2", withExtension: "jpg")
    let badUrlRequest = URLRequest(url: URL(string: "BadURL1//")!)
    let urlRequest = URLRequest(url: URL(string: "https://www.test.com/image.jpg")!)
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    override func setUp() async throws {
        try await super.setUp()
        
        testObject = ImageCacheService(launcher: mockTaskLauncher, diskCache: mockDiskCache)
    }
    
    private func cleanupDirectory() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory,includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch { print(error)}
    }
    
    // MARK: fetch()
    func test_fetch_givenUrlRequestFoundInsideOfImagesArray_returnImage() async {
        do {
            let image = try await testObject.fetch(urlRequest)
            XCTAssertNotNil(image)
        } catch {
            XCTFail("Should not throw error.")
        }
    }
    
    func test_fetch_givenNoMatchingURLRequestFoundInsideofImagesArrayOrInDiskCache_throwsError() async {
        mockDiskCache.retrieveCachedImageShouldReturnImage = false
        
        do {
            _ = try await testObject.fetch(badUrlRequest)
            XCTFail("Should throw error.")
        } catch {
            XCTAssertEqual(error.localizedDescription, "unsupported URL")
        }
    }
    
    // not sure how to test lines 39-43
    func test_fetch_givenNoMatchingURLRequestFoundInsideofImagesArray_successDownloadData() async {
        mockDiskCache.retrieveCachedImageShouldReturnImage = false
        mockDiskCache.cacheImageShouldNotThrow = true
        
        do {
            let image = try await testObject.fetch(URLRequest(url: imageOne!))
            XCTAssertNotNil(image)
            
        } catch {
            XCTFail("Should not throw.")
        }
    }
    
    func test_fetch_givenNoMatchingURLRequestFoundInsideofImagesArray_failDownloadDataThrowsError() async {
        mockDiskCache.retrieveCachedImageShouldReturnImage = false
        mockDiskCache.cacheImageShouldNotThrow = false
        
        do {
            _ = try await testObject.fetch(URLRequest(url: imageOne!))
            XCTFail("Should throw error.")
        } catch {
            XCTAssertEqual(error.localizedDescription, DiskCacheService.DiskCacheError.couldNotCreateData.localizedDescription)
        }
    }
    
    // MARK: getImageFromURLRequest()
    func test_getImageFromURLRequest_givenLoaderStatusFetched_returnImage() async {
        do {
            let image = try await testObject.fetch(URLRequest(url: imageOne!))
            XCTAssertNotNil(image)
            
        } catch {
            XCTFail("Should not throw.")
        }
    }
    
    // This is similar to loadImageFromFileSystem test, should I keep both?
    //    func test_fetch_givenAGoodUrl_withNoFile_shouldThrow() async {
    //        let url = URL(string: "file:///Volumes/fake.txt")
    //
    //        do {
    //            _ = try await testObject.fetch(URLRequest(url: url!))
    //            XCTFail("Should throw error.")
    //        } catch {
    //            XCTAssertEqual(error.localizedDescription, "The requested URL was not found on this server.")
    //        }
    //    }
    //
    //    func test_fetch_givenGoodURL_withFile_returnImage() async throws {
    //        let image = try await testObject.fetch(URLRequest(url: imageOne!))
    //        XCTAssertNotNil(image)
    //    }
    //
    //    func test_fetch_givenBadUrl_shouldThrow() async {
    //        let url = URL(string: "NotAURL://")
    //
    //        do {
    //            _ = try await testObject.fetch(URLRequest(url: url!))
    //            XCTFail("Should throw error.")
    //        } catch {
    //            XCTAssertEqual(error.localizedDescription, "unsupported URL")
    //        }
    //    }
    //
    //    // MARK: loadImageFromFileSystem()
    //    func test_fetch_givenIllegalUrl_attemptToGetData_shouldReturnNilData() async throws {
    //        let url = URL(string: "NotAURL://")
    //
    //        do {
    //            _ = try await testObject.fetch(URLRequest(url: url!))
    //            XCTFail("Should throw error.")
    //        } catch {
    //            XCTAssertEqual(error.localizedDescription, "unsupported URL")
    //        }
    //    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //    func test_fetch_givenFetchTask_returnInProgress() async throws {
    //        do {
    //            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory,includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    //            for fileURL in fileURLs {
    //                try FileManager.default.removeItem(at: fileURL)
    //            }
    //        } catch { print(error)}
    //
    //        mockTaskLauncher.shouldSuspendFirstTask = true
    //
    //        Task.detached() {
    //        try await self.testObject.fetch(URLRequest(url: URL(string: "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940")!))
    //        }
    //
    //        Task.detached() {
    //        try await self.testObject.fetch(URLRequest(url: URL(string: "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940")!))
    //        }
    //
    //        sleep(10)
    //    }
    //
    //        func test_fetch_givenMultipleDetachedTasks_returnInProgress() async throws {
    //            do {
    //                let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory,includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    //                for fileURL in fileURLs {
    //                    try FileManager.default.removeItem(at: fileURL)
    //                }
    //            } catch { print(error)}
    //
    //            Task.detached {
    //                for _ in 0...2 {
    //                    _ = try await self.testObject.fetch(URLRequest(url: URL(string: "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940")!))
    //                }
    //            }
    //
    //            Task.detached {
    //                for _ in 0...2 {
    //                    _ = try await self.testObject.fetch(URLRequest(url: URL(string: "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940")!))
    //                }
    //            }
    //
    //            Task.detached {
    //                for _ in 0...2 {
    //                    _ = try await self.testObject.fetch(URLRequest(url: URL(string: "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940")!))
    //                }
    //            }
    //
    //            sleep(3)
    //        }
}