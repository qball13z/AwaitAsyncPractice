import Foundation

protocol URLSessionProtocol {
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

public class APIManager: DataFetchable {
    enum UserFetchError: Error {
        case invalidURL
        case missingData
    }
    
    var session: URLSessionProtocol
    let apiURL: String
    
    init(session: URLSessionProtocol = URLSession.shared, apiURL: String = "https://randomuser.me/api/?results=") {
        self.session = session
        self.apiURL = apiURL
    }
    
    public func fetchUsers(resultCount: Int) async throws -> [User] {
        guard let url = URL(string: "\(self.apiURL)\(String(resultCount))") else {
            throw UserFetchError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url, delegate: nil)
        let userResult = try JSONDecoder().decode(UserResult.self, from: data)
        return userResult.results
    }
    
    public func loadUsers(numberOfUsersToFetch: Int) async throws -> [User] {
        let users = try await fetchUsers(resultCount: numberOfUsersToFetch)
        return users
    }
}

extension URLSession: URLSessionProtocol {}
