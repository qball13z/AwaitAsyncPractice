import XCTest
@testable import ActorsAwaitAsync

class ImageLoaderTests: XCTestCase {
    let imageLoader = ImageLoader()
    let imageOne = Bundle.init(for: ImageLoaderTests.self).url(forResource: "picture1", withExtension: "jpg")
    let imageTwo = Bundle.init(for: ImageLoaderTests.self).url(forResource: "picture2", withExtension: "jpg")
    
    func test_fetch_givenAGoodUrl_withNoFile_shouldThrow() async {
        let url = URL(string: "file:///Volumes/fake.txt")
        
        do {
            _ = try await imageLoader.fetch(url!)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "The requested URL was not found on this server.")
        }
    }
    
    func test_fetch_givenGoodURL_withFile_returnImage() async throws {
        let image = try await imageLoader.fetch(imageOne!)
        XCTAssertNotNil(image)
    }
    
    func test_fetch_givenBadUrl_shouldThrow() async {
        let url = URL(string: "NotAURL://")
        
        do {
            _ = try await imageLoader.fetch(url!)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "unsupported URL")
        }
    }
    
    func test_fetch_() async throws {
        Task.detached {
            for _ in 0...2 {
                _ = try await self.imageLoader.fetch(URLRequest(url: URL(string: "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940")!))
            }
        }
        
        Task.detached {
            for _ in 0...2 {
                _ = try await self.imageLoader.fetch(URLRequest(url: URL(string: "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940")!))
            }
        }
        
        Task.detached {
            for _ in 0...2 {
                _ = try await self.imageLoader.fetch(URLRequest(url: URL(string: "https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940")!))
            }
        }
        
        sleep(10)
        
        //        for _ in 0...10 {
        //        _ = try await imageLoader.fetch(URLRequest(url: URL(string: "https://randomuser.me/api/portraits/thumb/men/2.jpg")!))
        //        }
        //
        //        for _ in 0...10 {
        //        _ = try await imageLoader.fetch(URLRequest(url: URL(string: "https://randomuser.me/api/portraits/thumb/men/3.jpg")!))
        //        }
        
        
    }
}
