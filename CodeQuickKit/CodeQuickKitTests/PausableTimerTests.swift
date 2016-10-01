import XCTest
@testable import CodeQuickKit

class PausableTimerTests: XCTestCase, PausableTimerDelegate {
    
    var delegateExpectation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - PausableTimerDelegate
    func pausableTimer(_ timer: PausableTimer, percentComplete: Double) {
        if percentComplete == 1.0 {
            delegateExpectation?.fulfill()
        }
    }
    
    func testPausableCompletionHandler() {
        let completionExpectation = expectation(description: "PausableTimer completion fired")
        
        let _ = PausableTimer.makeTimer(timeInterval: 3) {
            completionExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 4) { (error) in
            print(error)
        }
    }
    
    func testPausableDelegate() {
        delegateExpectation = expectation(description: "PausableTimer delegate complete")
        
        let _ = PausableTimer.makeTimer(timeInterval: 3, delegate: self)
        
        waitForExpectations(timeout: 4) { (error) in
            print(error)
        }
    }
}
