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
    
}
