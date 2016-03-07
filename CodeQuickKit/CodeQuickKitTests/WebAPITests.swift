import XCTest
@testable import CodeQuickKit

class WebAPITests: XCTestCase {
    
    var api: WebAPI?
    
    override func setUp() {
        super.setUp()
        
        api = WebAPI(baseURL: NSURL(string: "http://www.example.com/api"), sessionDelegate: nil)
        guard let webApi = api else {
            XCTFail("WebAPI is nil")
            return
        }
        
        let injectedResponse = WebAPIInjectedResponse(statusCode: 200, responseObject: ["name": "Mock Me"], error: nil, timeout: 2)
        webApi.injectedResponses["http://www.example.com/api/test"] = injectedResponse
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInjectedResponse() {
        let expectation = expectationWithDescription("Injected Response")
        
        api!.get("test", queryItems: nil) { (statusCode, responseObject, error) -> Void in
            XCTAssertTrue(statusCode == 200)
            guard let dictionary = responseObject as? [String : String] else {
                XCTFail()
                return
            }
            guard dictionary["name"] == "Mock Me" else {
                XCTFail()
                return
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail()
            }
        }
    }
}
