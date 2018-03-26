import XCTest
@testable import CodeQuickKit

class DateTests: XCTestCase {
    let calendar = Calendar.current
    let timeZone = TimeZone(identifier: "GMT")!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testYesturday() {
        let now = Date()
        let yesturday = Date.yesturday
        
        XCTAssertTrue(yesturday.isBefore(now))
        
        guard let today = yesturday.dateByAdding(hours: 24) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isAfter(yesturday))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testTwoDaysAgo() {
        let now = Date()
        let twoDaysAgo = Date.twoDaysAgo
        
        XCTAssertTrue(twoDaysAgo.isBefore(now))
        
        guard let today = twoDaysAgo.dateByAdding(days: 2) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isAfter(twoDaysAgo))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testLastWeek() {
        let now = Date()
        let lastWeek = Date.lastWeek
        
        XCTAssertTrue(lastWeek.isBefore(now))
        
        guard let today = lastWeek.dateByAdding(minutes: 10080) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isAfter(lastWeek))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testTomorrow() {
        let now = Date()
        let tomorrow = Date.tomorrow
        
        XCTAssertTrue(tomorrow.isAfter(now))
        
        guard let today = tomorrow.dateByAdding(hours: -24) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isBefore(tomorrow))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testDayAfterTomorrow() {
        let now = Date()
        let dayAfterTomorrow = Date.dayAfterTomorrow
        
        XCTAssertTrue(dayAfterTomorrow.isAfter(now))
        
        guard let today = dayAfterTomorrow.dateByAdding(days: -2) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isBefore(dayAfterTomorrow))
        XCTAssertTrue(now.isSame(today))
    }
    
    func testNextWeek() {
        let now = Date()
        let nextWeek = Date.nextWeek
        
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
        
        DateFormatter.rfc1123DateFormatter.timeZone = TimeZone(identifier: "GMT")
        
        var dateComponents = DateComponents()
        dateComponents.calendar = calendar
        dateComponents.timeZone = timeZone
        dateComponents.era = 1
        dateComponents.year = 1982
        dateComponents.month = 11
        dateComponents.day = 5
        dateComponents.hour = 8
        dateComponents.minute = 0
        dateComponents.second = 0
        
        guard let date = dateComponents.date else {
            XCTFail()
            return
        }
        
        guard let d1 = DateFormatter.rfc1123Date(fromString: string) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(date.isSame(d1))
        
        let s1 = DateFormatter.rfc1123String(fromDate: date)
        XCTAssertTrue(string == s1)
    }
    
    func testNSDateFormatterStyleFormatters() {
        let string = "Fri, 05 Nov 1982 08:00:00 GMT"
        
        guard let date = DateFormatter.rfc1123DateFormatter.date(from: string) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(DateFormatter.shortDateTimeFormatter.string(from: date) == "11/5/82, 8:00 AM")
        XCTAssertTrue(DateFormatter.shortDateOnlyFormatter.string(from: date) == "11/5/82")
        XCTAssertTrue(DateFormatter.shortTimeOnlyFormatter.string(from: date) == "8:00 AM")
        var actual = DateFormatter.mediumDateTimeFormatter.string(from: date)
        XCTAssertTrue(actual == "Nov 5, 1982 at 8:00:00 AM" || actual == "Nov 5, 1982, 8:00:00 AM")
        XCTAssertTrue(DateFormatter.mediumDateOnlyFormatter.string(from: date) == "Nov 5, 1982")
        XCTAssertTrue(DateFormatter.mediumTimeOnlyFormatter.string(from: date) == "8:00:00 AM")
        XCTAssertTrue(DateFormatter.longDateTimeFormatter.string(from: date) == "November 5, 1982 at 8:00:00 AM GMT")
        XCTAssertTrue(DateFormatter.longDateOnlyFormatter.string(from: date) == "November 5, 1982")
        XCTAssertTrue(DateFormatter.longTimeOnlyFormatter.string(from: date) == "8:00:00 AM GMT")
        XCTAssertTrue(DateFormatter.fullDateTimeFormatter.string(from: date) == "Friday, November 5, 1982 at 8:00:00 AM Greenwich Mean Time")
        XCTAssertTrue(DateFormatter.fullDateOnlyFormatter.string(from: date) == "Friday, November 5, 1982")
        XCTAssertTrue(DateFormatter.fullTimeOnlyFormatter.string(from: date) == "8:00:00 AM Greenwich Mean Time")
        
        guard TimeZone.current.identifier == "America/Chicago" else {
            return
        }
        
        if TimeZone.current.isDaylightSavingTime() {
            // minus 6:00
            XCTAssertTrue(DateFormatter.shortDateTimeFormatter.display.string(from: date) == "11/5/82, 2:00 AM")
            XCTAssertTrue(DateFormatter.shortDateOnlyFormatter.display.string(from: date) == "11/5/82")
            XCTAssertTrue(DateFormatter.shortTimeOnlyFormatter.display.string(from: date) == "2:00 AM")
            actual = DateFormatter.mediumDateTimeFormatter.display.string(from: date)
            XCTAssertTrue(actual == "Nov 5, 1982 at 2:00:00 AM" || actual == "Nov 5, 1982, 2:00:00 AM")
            XCTAssertTrue(DateFormatter.mediumDateOnlyFormatter.display.string(from: date) == "Nov 5, 1982")
            XCTAssertTrue(DateFormatter.mediumTimeOnlyFormatter.display.string(from: date) == "2:00:00 AM")
            XCTAssertTrue(DateFormatter.longDateTimeFormatter.display.string(from: date) == "November 5, 1982 at 2:00:00 AM CST")
            XCTAssertTrue(DateFormatter.longDateOnlyFormatter.display.string(from: date) == "November 5, 1982")
            XCTAssertTrue(DateFormatter.longTimeOnlyFormatter.display.string(from: date) == "2:00:00 AM CST")
            XCTAssertTrue(DateFormatter.fullDateTimeFormatter.display.string(from: date) == "Friday, November 5, 1982 at 2:00:00 AM Central Standard Time")
            XCTAssertTrue(DateFormatter.fullDateOnlyFormatter.display.string(from: date) == "Friday, November 5, 1982")
            XCTAssertTrue(DateFormatter.fullTimeOnlyFormatter.display.string(from: date) == "2:00:00 AM Central Standard Time")
        } else {
            // minus 5:00
            XCTAssertTrue(DateFormatter.shortDateTimeFormatter.display.string(from: date) == "11/5/82, 3:00 AM")
            XCTAssertTrue(DateFormatter.shortDateOnlyFormatter.display.string(from: date) == "11/5/82")
            XCTAssertTrue(DateFormatter.shortTimeOnlyFormatter.display.string(from: date) == "3:00 AM")
            actual = DateFormatter.mediumDateTimeFormatter.display.string(from: date)
            XCTAssertTrue(actual == "Nov 5, 1982 at 3:00:00 AM" || actual == "Nov 5, 1982, 3:00:00 AM")
            XCTAssertTrue(DateFormatter.mediumDateOnlyFormatter.display.string(from: date) == "Nov 5, 1982")
            XCTAssertTrue(DateFormatter.mediumTimeOnlyFormatter.display.string(from: date) == "3:00:00 AM")
            XCTAssertTrue(DateFormatter.longDateTimeFormatter.display.string(from: date) == "November 5, 1982 at 3:00:00 AM CDT")
            XCTAssertTrue(DateFormatter.longDateOnlyFormatter.display.string(from: date) == "November 5, 1982")
            XCTAssertTrue(DateFormatter.longTimeOnlyFormatter.display.string(from: date) == "3:00:00 AM CDT")
            XCTAssertTrue(DateFormatter.fullDateTimeFormatter.display.string(from: date) == "Friday, November 5, 1982 at 3:00:00 AM Central Daylight Time")
            XCTAssertTrue(DateFormatter.fullDateOnlyFormatter.display.string(from: date) == "Friday, November 5, 1982")
            XCTAssertTrue(DateFormatter.fullTimeOnlyFormatter.display.string(from: date) == "3:00:00 AM Central Daylight Time")
        }
    }
}
