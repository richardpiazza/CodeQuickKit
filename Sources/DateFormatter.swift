import Foundation

public extension Locale {
    static var enUSPosix: Locale {
        return Locale(identifier: "en_US_POSIX")
    }
}

public extension TimeZone {
    static var gmt: TimeZone {
        return TimeZone(identifier: "GMT")!
    }
}

/// ## DateFormat
///
/// Enum grouping the format options for `DateFormatter`s.
public enum DateFormat {
    case shortDateTime
    case shortDateOnly
    case shortTimeOnly
    case mediumDateTime
    case mediumDateOnly
    case mediumTimeOnly
    case longDateTime
    case longDateOnly
    case longTimeOnly
    case fullDateTime
    case fullDateOnly
    case fullTimeOnly
    
    public var dateStyle: DateFormatter.Style {
        switch self {
        case .shortDateTime, .shortDateOnly: return .short
        case .mediumDateTime, .mediumDateOnly: return .medium
        case .longDateTime, .longDateOnly: return .long
        case .fullDateTime, .fullDateOnly: return .full
        case .shortTimeOnly, .mediumTimeOnly, .longTimeOnly, .fullTimeOnly: return .none
        }
    }
    
    public var timeStyle: DateFormatter.Style {
        switch self {
        case .shortDateTime, .shortTimeOnly: return .short
        case .mediumDateTime, .mediumTimeOnly: return .medium
        case .longDateTime, .longTimeOnly: return .long
        case .fullDateTime, .fullTimeOnly: return .full
        case .shortDateOnly, .mediumDateOnly, .longDateOnly, .fullDateOnly: return .none
        }
    }
}

public extension DateFormatter {
    public convenience init(dateFormat format: DateFormat, locale: Locale = Locale.enUSPosix, timeZone: TimeZone = TimeZone.gmt) {
        self.init()
        self.dateStyle = format.dateStyle
        self.timeStyle = format.timeStyle
        self.locale = locale
        self.timeZone = timeZone
    }
}

/// Extension of `DateFormatter` adding static access to common formatters.
public extension DateFormatter {
    /// Collection of DateFormatters using the GMT TimeZone and en_US_Posix Locale.
    public struct GMT {
        /// Date Formatter using the .ShortStyle for both Date and Time
        /// ***Example:*** "11/5/82, 8:00 AM"
        public static let shortDateTimeFormatter: DateFormatter = DateFormatter(dateFormat: .shortDateTime)
        /// Date Formatter using the .ShortStyle for Date and .NoStyle for Time
        /// ***Example:*** "11/5/82"
        public static let shortDateOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .shortDateOnly)
        /// Date Formatter using the .NoStyle for Date and .ShortStyle for Time
        /// ***Example:*** "8:00 AM"
        public static let shortTimeOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .shortTimeOnly)
        /// Date Formatter using the .MediumStyle for both Date and Time
        /// ***Example:*** "Nov 5, 1982, 8:00:00 AM"
        public static let mediumDateTimeFormatter: DateFormatter = DateFormatter(dateFormat: .mediumDateTime)
        /// Date Formatter using the .MediumStyle for Date and .NoStyle for Time
        /// ***Example:*** "Nov 5, 1982"
        public static let mediumDateOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .mediumDateOnly)
        /// Date Formatter using the .NoStyle for Date and .MediumStyle for Time
        /// ***Example:*** "8:00:00 AM"
        public static let mediumTimeOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .mediumTimeOnly)
        /// Date Formatter using the .LongStyle for both Date and Time
        /// ***Example:*** "November 5, 1982 at 8:00:00 AM GMT"
        public static let longDateTimeFormatter: DateFormatter = DateFormatter(dateFormat: .longDateTime)
        /// Date Formatter using the .LongStyle for Date and .NoStyle for Time
        /// ***Example:*** "November 5, 1982"
        public static let longDateOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .longDateOnly)
        /// Date Formatter using the .NoStyle for Date and .LongStyle for Time
        /// ***Example:*** "8:00:00 AM GMT"
        public static let longTimeOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .longTimeOnly)
        /// Date Formatter using the .FullStyle for both Date and Time
        /// ***Example:*** "Friday, November 5, 1982 at 8:00:00 AM GMT"
        public static let fullDateTimeFormatter: DateFormatter = DateFormatter(dateFormat: .fullDateTime)
        /// Date Formatter using the .LongStyle for Date and .NoStyle for Time
        /// ***Example:*** "Friday, November 5, 1982"
        public static let fullDateOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .fullDateOnly)
        /// Date Formatter using the .NoStyle for Date and .LongStyle for Time
        /// ***Example:*** "8:00:00 AM GMT"
        public static let fullTimeOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .fullTimeOnly)
    }
    
    public struct Local {
        /// Date Formatter using the .ShortStyle for both Date and Time
        /// ***Example:*** "11/5/82, 8:00 AM"
        public static let shortDateTimeFormatter: DateFormatter = DateFormatter(dateFormat: .shortDateTime, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .ShortStyle for Date and .NoStyle for Time
        /// ***Example:*** "11/5/82"
        public static let shortDateOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .shortDateOnly, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .NoStyle for Date and .ShortStyle for Time
        /// ***Example:*** "8:00 AM"
        public static let shortTimeOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .shortTimeOnly, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .MediumStyle for both Date and Time
        /// ***Example:*** "Nov 5, 1982, 8:00:00 AM"
        public static let mediumDateTimeFormatter: DateFormatter = DateFormatter(dateFormat: .mediumDateTime, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .MediumStyle for Date and .NoStyle for Time
        /// ***Example:*** "Nov 5, 1982"
        public static let mediumDateOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .mediumDateOnly, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .NoStyle for Date and .MediumStyle for Time
        /// ***Example:*** "8:00:00 AM"
        public static let mediumTimeOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .mediumTimeOnly, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .LongStyle for both Date and Time
        /// ***Example:*** "November 5, 1982 at 8:00:00 AM GMT"
        public static let longDateTimeFormatter: DateFormatter = DateFormatter(dateFormat: .longDateTime, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .LongStyle for Date and .NoStyle for Time
        /// ***Example:*** "November 5, 1982"
        public static let longDateOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .longDateOnly, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .NoStyle for Date and .LongStyle for Time
        /// ***Example:*** "8:00:00 AM GMT"
        public static let longTimeOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .longTimeOnly, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .FullStyle for both Date and Time
        /// ***Example:*** "Friday, November 5, 1982 at 8:00:00 AM GMT"
        public static let fullDateTimeFormatter: DateFormatter = DateFormatter(dateFormat: .fullDateTime, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .LongStyle for Date and .NoStyle for Time
        /// ***Example:*** "Friday, November 5, 1982"
        public static let fullDateOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .fullDateOnly, locale: Locale.current, timeZone: TimeZone.current)
        /// Date Formatter using the .NoStyle for Date and .LongStyle for Time
        /// ***Example:*** "8:00:00 AM GMT"
        public static let fullTimeOnlyFormatter: DateFormatter = DateFormatter(dateFormat: .fullTimeOnly, locale: Locale.current, timeZone: TimeZone.current)
    }
}
