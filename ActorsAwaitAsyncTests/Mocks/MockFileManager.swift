import XCTest
import Foundation
@testable import ActorsAwaitAsync

class MockFileManager: FileManagerProtocol {
    var createUrlToObject = true
    var localPathToObject = "GoodPath"
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        if createUrlToObject {
            return [URL(string: "Url://to/object")!]
        } else {
            return []
        }
    }
    
    func contents(atPath: String) -> Data? {
        if atPath == localPathToObject {
            return Data()
        } else {
            return nil
        }
    }
}
