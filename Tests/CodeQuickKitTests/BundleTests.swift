import XCTest
@testable import CodeQuickKit

class BundleTests: XCTestCase {

    static var allTests = [
        ("testBundleDictionary", testBundleDictionary),
    ]

    func testBundleDictionary() {
        let dictionary = Bundle.main.presentableDictionary
        XCTAssertTrue(dictionary.keys.contains(Bundle.Keys.BundleName))
    }
}
