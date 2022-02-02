import XCTest
import Foundation
@testable import ActorsAwaitAsync

class MockFileManager: FileManagerProtocol {
    var urlToObject = URL(string: "URL://")!
    var localPathToObject = "GoodPath"
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return [urlToObject]
    }
    
    func contents(atPath: String) -> Data? {
        if atPath == localPathToObject {
            return Data()
        } else {
            return nil
        }
    }
}
