import XCTest
import ActorsAwaitAsync
@testable import ActorsAwaitAsync

class APIManagerTests: XCTestCase {
    var mockURLSession: MockURLSession!
    var apiManager: APIManager!
    
    // MARK: LoadUsers()
    func test_loadUsers_givensuccess_returnUserCount() async throws {
        mockURLSession = MockURLSession(data: jsonData(), urlResponse: response(statusCode: 200))
        apiManager = APIManager(session: mockURLSession)
        
        let userCount = 1
        let users = try await apiManager.loadUsers(numberOfUsersToFetch: userCount)
        XCTAssertEqual(users.count, userCount)
    }
    
    // MARK: FetchUsers()
    func test_fetchUsers_givenInvalidURL_throwInvalidURLError() async throws {
        mockURLSession = MockURLSession(data: jsonData(), urlResponse: response(statusCode: 200))
        apiManager = APIManager(session: mockURLSession, apiURL: "˚_-[]{}!@#$%^&*()•ª¶§∞¢£™¡")
        let userCount = 1
        
        do {
            let users = try await apiManager.loadUsers(numberOfUsersToFetch: userCount)
            XCTFail("This should throw.")
        } catch {
            XCTAssertEqual(APIManager.UserFetchError.invalidURL, error as! APIManager.UserFetchError)
        }
    }
    
    // Test Failing Status Codes
    // Test return session throws
    // Test Returning no users
    // Test failed decoding - GIVE IT GARBAGE DATA
}

class MockURLSession: URLSessionProtocol {
    var data: Data
    var urlResponse: URLResponse
    
    init(data: Data?, urlResponse: URLResponse?) {
        self.data = data!
        self.urlResponse = urlResponse!
    }
    
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        // Do we need an await in here for this async method to be valid???
        // No, because it's always called from an async context
        return (self.data, self.urlResponse)
    }
}

private func badJsonData() -> Data {
    """
        {{
    """.data(using: .utf8)!
}

private func jsonData() -> Data {
    """
{"results":[{"gender":"female","name":{"title":"Mrs","first":"Vandana","last":"Den Braber"},"location":{"street":{"number":5694,"name":"Beukenoord"},"city":"Nieuw-Lekkerland","state":"Limburg","country":"Netherlands","postcode":63781,"coordinates":{"latitude":"46.1097","longitude":"33.8785"},"timezone":{"offset":"-3:00","description":"Brazil, Buenos Aires, Georgetown"}},"email":"vandana.denbraber@example.com","login":{"uuid":"e2a59296-9913-4a85-9131-bc39f0073397","username":"beautifulostrich818","password":"claude","salt":"JfoQHu1g","md5":"8bfd493bde6b1739fbd813f4e2f9409b","sha1":"a582ef57d8ac63a9a873477afea37bd9eebcef49","sha256":"b2ae071ee3f253ab3e508688a70c8080aeb3cc5ebdbf4cd7f1e94c13cad43a4c"},"dob":{"date":"1956-03-29T20:30:05.213Z","age":66},"registered":{"date":"2012-08-23T03:27:07.316Z","age":10},"phone":"(004)-225-4701","cell":"(160)-041-8778","id":{"name":"BSN","value":"44859145"},"picture":{"large":"https://randomuser.me/api/portraits/women/96.jpg","medium":"https://randomuser.me/api/portraits/med/women/96.jpg","thumbnail":"https://randomuser.me/api/portraits/thumb/women/96.jpg"},"nat":"NL"}],"info":{"seed":"6aa112653d4a7844","results":1,"page":1,"version":"1.3"}}
""".data(using: .utf8)!
}

private func response(statusCode: Int) -> HTTPURLResponse? {
    HTTPURLResponse(url: URL(string: "http://mock")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
}
