import XCTest
import Foundation
@testable import ActorsAwaitAsync

class MockFileManager: FileManagerProtocol {
    var objectUrl: URL? = URL(string: "file:///to/object")
    var contentsToReturn: Data? = Data()
    var capturedUrlDirectory: FileManager.SearchPathDirectory?
    var capturedUrlDomainMask: FileManager.SearchPathDomainMask?
    var capturedPath: String?
    var urlsWasCalled = false
    var contentsWasCalled = false
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        capturedUrlDirectory = directory
        capturedUrlDomainMask = domainMask
        urlsWasCalled = true
        
        if let objectUrl = objectUrl {
            return [objectUrl]
        } else {
            return []
        }
    }
    
    func contents(atPath: String) -> Data? {
        capturedPath = atPath
        contentsWasCalled = true
        return contentsToReturn
    }
}
