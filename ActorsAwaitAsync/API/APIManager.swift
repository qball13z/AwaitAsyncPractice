import Foundation

protocol URLSessionProtocol {
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

public class APIManager: DataFetchable {
    enum UserFetchError: Error {
        case invalidURL
        case serverRequestError
        case unableToDecodeError
        case failedRequestError
        case genericRequestError
    }
    
    var session: URLSessionProtocol
    let apiURL: String
    
    init(session: URLSessionProtocol = URLSession.shared, apiURL: String = "https://randomuser.me/api/?results=") {
        self.session = session
        self.apiURL = apiURL
    }
    
    public func fetchUsers(resultCount: Int) async throws -> [User] {
        if resultCount < 1 {
            return []
        }
        
        guard let url = URL(string: "\(self.apiURL)\(String(resultCount))") else {
            throw UserFetchError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url, delegate: nil)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            switch httpResponse.statusCode {
            case 400...499:
                throw UserFetchError.failedRequestError
            case 500...599:
                throw UserFetchError.serverRequestError
            default:
                throw UserFetchError.genericRequestError
            }
        }
        
        guard let userResult = try? JSONDecoder().decode(UserResult.self, from: data) else {
            throw UserFetchError.unableToDecodeError
        }
        return userResult.results
    }
    
    public func loadUsers(numberOfUsersToFetch: Int) async throws -> [User] {
        let users = try await fetchUsers(resultCount: numberOfUsersToFetch)
        return users
    }
}

extension URLSession: URLSessionProtocol {}
