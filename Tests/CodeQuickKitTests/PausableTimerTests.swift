import XCTest
@testable import CodeQuickKit

class PausableTimerTests: XCTestCase, PausableTimerDelegate {
    
    static var allTests = [
        ("testPausableCompletionHandler", testPausableCompletionHandler),
        ("testPausableDelegate", testPausableDelegate),
    ]
    
    var delegateExpectation: XCTestExpectation?
    
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
            if let e = error {
                print(e)
            }
        }
    }
    
    func testPausableDelegate() {
        delegateExpectation = expectation(description: "PausableTimer delegate complete")
        
        let _ = PausableTimer.makeTimer(timeInterval: 3, delegate: self)
        
        waitForExpectations(timeout: 4) { (error) in
            if let e = error {
                print(e)
            }
        }
    }
}
