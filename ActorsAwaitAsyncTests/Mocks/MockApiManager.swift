import UIKit
@testable import ActorsAwaitAsync

class MockApiManager: DataFetchable {
    enum MockAPIManagerError: Error {
        case invalidURL
        case serverRequestError
        case unableToDecodeError
        case failedRequestError
        case genericRequestError
        case loadUserError
        case fetchUserError
    }
    
    var loadUsersCapturedNumberOfUsers: Int = 0
    var loadUsersReturnPersonValue = [Person]()
    var loadUsersShouldReturnPerson = true
    
    var fetchUsersCapturedResultCount: Int = 0
    var fetchUsersReturnPersonValue = [Person]()
    var fetchUsersShouldReturnPerson = true
    
    let capturedURLSesion: URLSessionProtocol
    let capturedAPIUrl: String
    
    init(session: URLSessionProtocol = URLSession.shared, apiURL: String = "https://randomuser.me/api/?results=") {
        capturedURLSesion = session
        capturedAPIUrl = apiURL
    }
    
    func fetchUsers(resultCount: Int) async throws -> [Person] {
        fetchUsersCapturedResultCount = resultCount
        
        if !fetchUsersShouldReturnPerson {
            throw MockAPIManagerError.fetchUserError
        }
        
        return fetchUsersReturnPersonValue
    }
    
    func loadUsers(numberOfUsersToFetch: Int) async throws -> [Person] {
        loadUsersCapturedNumberOfUsers = numberOfUsersToFetch
        
        if !loadUsersShouldReturnPerson {
            throw MockAPIManagerError.loadUserError
        }
        
        return loadUsersReturnPersonValue
    }
}
