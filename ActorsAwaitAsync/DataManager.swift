import Foundation

struct DataManager {
    enum UserFetchError: Error {
        case invalidURL
        case missingData
    }
    
    static func fetchUsers(resultCount: Int) async throws -> [User] {
        guard let url = URL(string: "https://randomuser.me/api/?results=\(String(resultCount))") else {
            throw UserFetchError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let userResult = try JSONDecoder().decode(UserResult.self, from: data)
        return userResult.results
    }
}
