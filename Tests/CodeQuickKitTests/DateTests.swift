import XCTest
@testable import CodeQuickKit

class DateTests: XCTestCase {
    
    static var allTests = [
        ("testYesterday", testYesterday),
        ("testTwoDaysAgo", testTwoDaysAgo),
        ("testLastWeek", testLastWeek),
        ("testTomorrow", testTomorrow),
        ("testDayAfterTomorrow", testDayAfterTomorrow),
        ("testNextWeek", testNextWeek),
        ("testRFC1123DateFormatter", testRFC1123DateFormatter),
        ("testNSDateFormatterStyleFormatters", testNSDateFormatterStyleFormatters),
    ]
    
    let calendar = Calendar.current
    let timeZone = TimeZone(identifier: "GMT")!
    
    var rfc1124DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
        formatter.timeZone = TimeZone(identifier: "GMT")!
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func testYesterday() {
        let now = Date()
        let yesterday = Date.yesterday
        
        XCTAssertTrue(yesterday.isBefore(now))
        
        guard let today = yesterday.dateByAdding(hours: 24) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(today.isAfter(yesterday))
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
        
        rfc1124DateFormatter.timeZone = timeZone
        
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
        
        guard let d1 = rfc1124DateFormatter.date(from: string) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(date.isSame(d1))
        
        let s1 = rfc1124DateFormatter.string(from: date)
        XCTAssertTrue(string == s1)
    }
    
    func testNSDateFormatterStyleFormatters() {
        let string = "Fri, 05 Nov 1982 08:00:00 GMT"
        
        guard let date = rfc1124DateFormatter.date(from: string) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(DateFormatter.GMT.shortDateTimeFormatter.string(from: date) == "11/5/82, 8:00 AM")
        XCTAssertTrue(DateFormatter.GMT.shortDateOnlyFormatter.string(from: date) == "11/5/82")
        XCTAssertTrue(DateFormatter.GMT.shortTimeOnlyFormatter.string(from: date) == "8:00 AM")
        var actual = DateFormatter.GMT.mediumDateTimeFormatter.string(from: date)
        XCTAssertTrue(actual == "Nov 5, 1982 at 8:00:00 AM" || actual == "Nov 5, 1982, 8:00:00 AM")
        XCTAssertTrue(DateFormatter.GMT.mediumDateOnlyFormatter.string(from: date) == "Nov 5, 1982")
        XCTAssertTrue(DateFormatter.GMT.mediumTimeOnlyFormatter.string(from: date) == "8:00:00 AM")
        XCTAssertTrue(DateFormatter.GMT.longDateTimeFormatter.string(from: date) == "November 5, 1982 at 8:00:00 AM GMT")
        XCTAssertTrue(DateFormatter.GMT.longDateOnlyFormatter.string(from: date) == "November 5, 1982")
        XCTAssertTrue(DateFormatter.GMT.longTimeOnlyFormatter.string(from: date) == "8:00:00 AM GMT")
        XCTAssertTrue(DateFormatter.GMT.fullDateTimeFormatter.string(from: date) == "Friday, November 5, 1982 at 8:00:00 AM Greenwich Mean Time")
        XCTAssertTrue(DateFormatter.GMT.fullDateOnlyFormatter.string(from: date) == "Friday, November 5, 1982")
        XCTAssertTrue(DateFormatter.GMT.fullTimeOnlyFormatter.string(from: date) == "8:00:00 AM Greenwich Mean Time")
        
        guard TimeZone.current.identifier == "America/Chicago" else {
            return
        }
        
        XCTAssertEqual(DateFormatter.Local.shortDateTimeFormatter.string(from: date), "11/5/82, 2:00 AM")
        XCTAssertEqual(DateFormatter.Local.shortDateOnlyFormatter.string(from: date), "11/5/82")
        XCTAssertEqual(DateFormatter.Local.shortTimeOnlyFormatter.string(from: date), "2:00 AM")
        actual = DateFormatter.Local.mediumDateTimeFormatter.string(from: date)
        XCTAssertTrue(actual == "Nov 5, 1982 at 2:00:00 AM" || actual == "Nov 5, 1982, 2:00:00 AM")
        XCTAssertEqual(DateFormatter.Local.mediumDateOnlyFormatter.string(from: date), "Nov 5, 1982")
        XCTAssertEqual(DateFormatter.Local.mediumTimeOnlyFormatter.string(from: date), "2:00:00 AM")
        XCTAssertEqual(DateFormatter.Local.longDateTimeFormatter.string(from: date), "November 5, 1982 at 2:00:00 AM CST")
        XCTAssertEqual(DateFormatter.Local.longDateOnlyFormatter.string(from: date), "November 5, 1982")
        XCTAssertEqual(DateFormatter.Local.longTimeOnlyFormatter.string(from: date), "2:00:00 AM CST")
        XCTAssertEqual(DateFormatter.Local.fullDateTimeFormatter.string(from: date), "Friday, November 5, 1982 at 2:00:00 AM Central Standard Time")
        XCTAssertEqual(DateFormatter.Local.fullDateOnlyFormatter.string(from: date), "Friday, November 5, 1982")
        XCTAssertEqual(DateFormatter.Local.fullTimeOnlyFormatter.string(from: date), "2:00:00 AM Central Standard Time")
    }
}
