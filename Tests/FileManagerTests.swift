import XCTest
@testable import CodeQuickKit

class FileManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        if let directory = FileManager.default.sandboxDocumentsDirectory {
            print("Sandbox Directory: \(directory)")
        } else {
            print("Sandbox Directory: NONE")
        }
        
        Log.writeToFile = true
        Log.info("Ensure Log File Generated")
        print("Log File: \(LogFile.default.url)")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLogRetrieval() {
        let urls = FileManager.default.sandboxDocuments(withExtension: "txt")
        guard let url = urls.first else {
            XCTFail("No Sandbox Documents Found")
            return
        }
        
        XCTAssertEqual(url, LogFile.default.url)
    }
}
