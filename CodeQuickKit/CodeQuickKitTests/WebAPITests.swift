import XCTest
@testable import CodeQuickKit

class WebAPITests: XCTestCase {
    
    var api: WebAPI?
    
    override func setUp() {
        super.setUp()
        
        api = WebAPI(baseURL: URL(string: "http://www.example.com/api"), sessionDelegate: nil)
        guard let webApi = api else {
            XCTFail("WebAPI is nil")
            return
        }
        
        let responseObject: AnyObject = ["name":"Mock Me"] as AnyObject
        
        let injectedResponse = WebAPIInjectedResponse(statusCode: 200, response: nil, responseObject: responseObject, error: nil, timeout: 2)
        webApi.injectedResponses["http://www.example.com/api/test"] = injectedResponse
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInjectedResponse() {
        let expectation = self.expectation(description: "Injected Response")
        
        api!.get("test", queryItems: nil) { (statusCode, response, responseObject, error) -> Void in
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
        
        waitForExpectations(timeout: 5) { (error) in
            if let _ = error {
                XCTFail()
            }
        }
    }
    
    func testIPv6DNSError() {
        let expectation = self.expectation(description: "IPv6 DNS Error")
        
        let invalidApi = WebAPI(baseURL: URL(string: "https://api.richardpiazza.com"), sessionDelegate: nil)
        invalidApi.get("") { (statusCode, response, responseObject, error) in
            guard let e = error else {
                XCTFail()
                return
            }
            
            print(e)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let _ = error {
                XCTFail()
            }
        }
    }
}
