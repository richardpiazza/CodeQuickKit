import XCTest
@testable import CodeQuickKit

class BundleTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        print(Bundle.main)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBundleDictionary() {
        let dictionary = Bundle.main.dictionary
        XCTAssertTrue(dictionary.keys.contains(Bundle.Keys.BundleName))
    }
}