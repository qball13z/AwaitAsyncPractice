import Foundation

public class APIManager: DataFetchable {
    enum UserFetchError: Error {
        case invalidURL
        case missingData
    }
    
    public func fetchUsers(resultCount: Int) async throws -> [User] {
        guard let url = URL(string: "https://randomuser.me/api/?results=\(String(resultCount))") else {
            throw UserFetchError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let userResult = try JSONDecoder().decode(UserResult.self, from: data)
        return userResult.results
    }
    
    // Throw in future : TODO
    public func loadUsers(userCount: Int) async -> [User] {
        let loadTask = Task { () -> [User] in
            do {
                let users = try await fetchUsers(resultCount: userCount)
                return users
            } catch {
                print("Failed with error: \(error)")
                return []
            }
        }
        return await loadTask.value
    }
}
