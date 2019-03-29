import Foundation

public extension Date {
    /// Provides the current datetime minus 24 hours.
    static var yesturday: Date {
        return Date().dateByAdding(days: -1)!
    }
    
    /// Provides the current datetime minus 48 hours.
    static var twoDaysAgo: Date {
        return Date().dateByAdding(days: -2)!
    }
    
    /// Provides the current datetime minus 7 days.
    static var lastWeek: Date {
        return Date().dateByAdding(days: -7)!
    }
    
    /// Provides the current datetime plus 24 hours.
    static var tomorrow: Date {
        return Date().dateByAdding(days: 1)!
    }
    
    /// Provides the current datetime plus 48 days.
    static var dayAfterTomorrow: Date {
        return Date().dateByAdding(days: 2)!
    }
    
    /// Provides the current datetime plus 7 days.
    static var nextWeek: Date {
        return Date().dateByAdding(days: 7)!
    }
    
    /// Determines if the instance date is before the reference date (second granularity).
    func isBefore(_ date: Date) -> Bool {
        return Calendar.current.compare(self, to: date, toGranularity: .second) == .orderedAscending
    }
    
    /// Determines if the instance date is after the reference date (second granularity).
    func isAfter(_ date: Date) -> Bool {
        return Calendar.current.compare(self, to: date, toGranularity: .second) == .orderedDescending
    }
    
    /// Determines if the instance date is equal to the reference date (second granularity).
    func isSame(_ date: Date) -> Bool {
        return Calendar.current.compare(self, to: date, toGranularity: .second) == .orderedSame
    }
    
    /// Uses `Calendar` to return the instance date mutated by the specified number of minutes.
    func dateByAdding(minutes value: Int) -> Date? {
        return Calendar.current.date(byAdding: .minute, value: value, to: self)
    }
    
    /// Uses `Calendar` to return the instance date mutated by the specified number of hours.
    func dateByAdding(hours value: Int) -> Date? {
        return Calendar.current.date(byAdding: .hour, value: value, to: self)
    }
    
    /// Uses `Calendar` to return the instance date mutated by the specified number of days.
    func dateByAdding(days value: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: value, to: self)
    }
}
