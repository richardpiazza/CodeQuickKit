//===----------------------------------------------------------------------===//
//
// NSDateFormatter.swift
//
// Copyright (c) 2016 Richard Piazza
// https://github.com/richardpiazza/CodeQuickKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//===----------------------------------------------------------------------===//

import Foundation

/// ## DateFormat
///
/// Enum grouping the format options for `NSDateFormatter`s.
public enum DateFormat {
    case RFC1123
    case ShortDateTime
    case ShortDateOnly
    case ShortTimeOnly
    case MediumDateTime
    case MediumDateOnly
    case MediumTimeOnly
    case LongDateTime
    case LongDateOnly
    case LongTimeOnly
    case FullDateTime
    case FullDateOnly
    case FullTimeOnly
    
    var dateFormat: String? {
        switch self {
        case .RFC1123: return "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
        default: return nil
        }
    }
    
    var dateStyle: NSDateFormatterStyle? {
        switch self {
        case .ShortDateTime, .ShortDateOnly: return .ShortStyle
        case .MediumDateTime, .MediumDateOnly: return .MediumStyle
        case .LongDateTime, .LongDateOnly: return .LongStyle
        case .FullDateTime, .FullDateOnly: return .FullStyle
        case .ShortTimeOnly, .MediumTimeOnly, .LongTimeOnly, .FullTimeOnly: return .NoStyle
        default: return nil
        }
    }
    
    var timeStyle: NSDateFormatterStyle? {
        switch self {
        case .ShortDateTime, .ShortTimeOnly: return .ShortStyle
        case .MediumDateTime, .MediumTimeOnly: return .MediumStyle
        case .LongDateTime, .LongTimeOnly: return .LongStyle
        case .FullDateTime, .FullTimeOnly: return .FullStyle
        case .ShortDateOnly, .MediumDateOnly, .LongDateOnly, .FullDateOnly: return .NoStyle
        default: return nil
        }
    }
    
    var locale: NSLocale {
        switch self {
        default: return NSLocale(localeIdentifier: "en_US")
        }
    }
    
    var timeZone: NSTimeZone {
        switch self {
        default: return NSTimeZone(abbreviation: "GMT")!
        }
    }
}

/// Extension of `NSDateFormatter` adding static access to common formatters.
public extension NSDateFormatter {
    private struct common {
        static let rfc1123DateFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .RFC1123)
        static let shortDateTimeFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .ShortDateTime)
        static let shortDateOnlyFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .ShortDateOnly)
        static let shortTimeOnlyFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .ShortTimeOnly)
        static let mediumDateTimeFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .MediumDateTime)
        static let mediumDateOnlyFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .MediumDateOnly)
        static let mediumTimeOnlyFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .MediumTimeOnly)
        static let longDateTimeFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .LongDateTime)
        static let longDateOnlyFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .LongDateOnly)
        static let longTimeOnlyFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .LongTimeOnly)
        static let fullDateTimeFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .FullDateTime)
        static let fullDateOnlyFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .FullDateOnly)
        static let fullTimeOnlyFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .FullTimeOnly)
    }
    
    public convenience init(withDateFormat format: DateFormat) {
        self.init()
        if let dateFormat = format.dateFormat {
            self.dateFormat = dateFormat
        }
        if let dateStyle = format.dateStyle {
            self.dateStyle = dateStyle
        }
        if let timeStyle = format.timeStyle {
            self.timeStyle = timeStyle
        }
        locale = format.locale
        timeZone = format.timeZone
    }
    
    /// DateFormatter with the format "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
    ///
    /// ***Example:*** "Fri, 05 Nov 1982 08:00:00 GMT"
    public static var rfc1123DateFormatter: NSDateFormatter {
        return common.rfc1123DateFormatter
    }
    
    public static func rfc1123Date(fromString string: String) -> NSDate? {
        return common.rfc1123DateFormatter.dateFromString(string)
    }
    
    public static func rfc1123String(fromDate date: NSDate) -> String {
        return common.rfc1123DateFormatter.stringFromDate(date)
    }
    
    /// Date Formatter using the .ShortStyle for both Date and Time
    /// ***Example:*** "11/5/82, 8:00 AM"
    public static var shortDateTimeFormatter: NSDateFormatter {
        return common.shortDateTimeFormatter
    }
    
    /// Date Formatter using the .ShortStyle for Date and .NoStyle for Time
    /// ***Example:*** "11/5/82"
    public static var shortDateOnlyFormatter: NSDateFormatter {
        return common.shortDateOnlyFormatter
    }
    
    /// Date Formatter using the .NoStyle for Date and .ShortStyle for Time
    /// ***Example:*** "8:00 AM"
    public static var shortTimeOnlyFormatter: NSDateFormatter {
        return common.shortTimeOnlyFormatter
    }
    
    /// Date Formatter using the .MediumStyle for both Date and Time
    /// ***Example:*** "Nov 5, 1982, 8:00:00 AM"
    public static var mediumDateTimeFormatter: NSDateFormatter {
        return common.mediumDateTimeFormatter
    }
    
    /// Date Formatter using the .MediumStyle for Date and .NoStyle for Time
    /// ***Example:*** "Nov 5, 1982"
    public static var mediumDateOnlyFormatter: NSDateFormatter {
        return common.mediumDateOnlyFormatter
    }
    
    /// Date Formatter using the .NoStyle for Date and .MediumStyle for Time
    /// ***Example:*** "8:00:00 AM"
    public static var mediumTimeOnlyFormatter: NSDateFormatter {
        return common.mediumTimeOnlyFormatter
    }
    
    /// Date Formatter using the .LongStyle for both Date and Time
    /// ***Example:*** "November 5, 1982 at 8:00:00 AM GMT"
    public static var longDateTimeFormatter: NSDateFormatter {
        return common.longDateTimeFormatter
    }
    
    /// Date Formatter using the .LongStyle for Date and .NoStyle for Time
    /// ***Example:*** "November 5, 1982"
    public static var longDateOnlyFormatter: NSDateFormatter {
        return common.longDateOnlyFormatter
    }
    
    /// Date Formatter using the .NoStyle for Date and .LongStyle for Time
    /// ***Example:*** "8:00:00 AM GMT"
    public static var longTimeOnlyFormatter: NSDateFormatter {
        return common.longTimeOnlyFormatter
    }
    
    /// Date Formatter using the .FullStyle for both Date and Time
    /// ***Example:*** "Friday, November 5, 1982 at 8:00:00 AM GMT"
    public static var fullDateTimeFormatter: NSDateFormatter {
        return common.fullDateTimeFormatter
    }
    
    /// Date Formatter using the .LongStyle for Date and .NoStyle for Time
    /// ***Example:*** "Friday, November 5, 1982"
    public static var fullDateOnlyFormatter: NSDateFormatter {
        return common.fullDateOnlyFormatter
    }
    
    /// Date Formatter using the .NoStyle for Date and .LongStyle for Time
    /// ***Example:*** "8:00:00 AM GMT"
    public static var fullTimeOnlyFormatter: NSDateFormatter {
        return common.fullTimeOnlyFormatter
    }
}
