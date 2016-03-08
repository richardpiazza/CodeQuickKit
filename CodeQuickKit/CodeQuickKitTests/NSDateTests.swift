import XCTest
@testable import CodeQuickKit

class NSDateTests: XCTestCase {
    let calendar = NSCalendar.currentCalendar()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testYesturday() {
        let now = NSDate()
        let yesturday = NSDate.yesturday
        
        XCTAssertTrue(yesturday.isBefore(now))
        
        guard let today = yesturday.dateByAdding(hours: 24) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isAfter(yesturday))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testTwoDaysAgo() {
        let now = NSDate()
        let twoDaysAgo = NSDate.twoDaysAgo
        
        XCTAssertTrue(twoDaysAgo.isBefore(now))
        
        guard let today = twoDaysAgo.dateByAdding(days: 2) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isAfter(twoDaysAgo))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testLastWeek() {
        let now = NSDate()
        let lastWeek = NSDate.lastWeek
        
        XCTAssertTrue(lastWeek.isBefore(now))
        
        guard let today = lastWeek.dateByAdding(minutes: 10080) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isAfter(lastWeek))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testTomorrow() {
        let now = NSDate()
        let tomorrow = NSDate.tomorrow
        
        XCTAssertTrue(tomorrow.isAfter(now))
        
        guard let today = tomorrow.dateByAdding(hours: -24) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isBefore(tomorrow))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testDayAfterTomorrow() {
        let now = NSDate()
        let dayAfterTomorrow = NSDate.dayAfterTomorrow
        
        XCTAssertTrue(dayAfterTomorrow.isAfter(now))
        
        guard let today = dayAfterTomorrow.dateByAdding(days: -2) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isBefore(dayAfterTomorrow))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testNextWeek() {
        let now = NSDate()
        let nextWeek = NSDate.nextWeek
        
        XCTAssertTrue(nextWeek.isAfter(now))
        
        guard let today = nextWeek.dateByAdding(minutes: -10080) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isBefore(nextWeek))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testRFC1123DateFormatter() {
        let string = "Fri, 05 Nov 1982 08:00:00 GMT"
        let date = NSCalendar.currentCalendar().dateWithEra(1, year: 1982, month: 11, day: 5, hour: 16, minute: 0, second: 0, nanosecond: 0)!
        
        guard let d1 = NSDateFormatter.rfc1123Date(fromString: string) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(date.isSame(d1))
        
        let s1 = NSDateFormatter.rfc1123String(fromDate: date)
        XCTAssertTrue(string == s1)
    }
}
