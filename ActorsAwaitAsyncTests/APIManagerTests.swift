import XCTest
import ActorsAwaitAsync
@testable import ActorsAwaitAsync

class APIManagerTests: XCTestCase {
    var apiManager = APIManager()
    
    func test_get_request_withUserCount() async {
        let userCount = 3
        
        let users = await apiManager.loadUsers(userCount: userCount)
        
        XCTAssertEqual(users.count, userCount)
        
    }

}
