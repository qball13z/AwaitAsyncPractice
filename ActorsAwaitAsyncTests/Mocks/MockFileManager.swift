import XCTest
import Foundation
@testable import ActorsAwaitAsync

class MockFileManager: FileManagerProtocol {
    var documentsDirectoryUrl: URL? = URL(string: "file:///to/object")
    var contentsToReturn: Data? = Data()
    var capturedUrlDirectory: FileManager.SearchPathDirectory?
    var capturedUrlDomainMask: FileManager.SearchPathDomainMask?
    var capturedPath: String?
    var urlsWasCalled = false
    var contentsWasCalled = false
    var createFileSuccess = true
    var fileExistsAtPath = false
    var didRemoveItemCalled = false
    let removeItemError: Error? = nil
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        capturedUrlDirectory = directory
        capturedUrlDomainMask = domainMask
        urlsWasCalled = true
        
        if let objectUrl = documentsDirectoryUrl {
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
    
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool {
        return createFileSuccess
    }
    
    func fileExists(atPath: String) -> Bool {
        return fileExistsAtPath
    }
    
    func removeItem(at: URL) throws {
        didRemoveItemCalled = true
        
        if let removeItemError = removeItemError {
            throw removeItemError
        }
    }

}
