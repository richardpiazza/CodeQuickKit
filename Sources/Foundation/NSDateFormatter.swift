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

public enum DateFormat {
    case RFC1123
    
    var dateFormat: String {
        switch self {
        case .RFC1123: return "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
        }
    }
    
    var locale: NSLocale {
        switch self {
        case .RFC1123: return NSLocale(localeIdentifier: "en_US")
        }
    }
    
    var timeZone: NSTimeZone {
        switch self {
        case .RFC1123: return NSTimeZone(abbreviation: "GMT")!
        }
    }
}

public extension NSDateFormatter {
    private struct common {
        static let rfc1123DateFormatter: NSDateFormatter = NSDateFormatter(withDateFormat: .RFC1123)
    }
    
    public convenience init(withDateFormat format: DateFormat) {
        self.init()
        dateFormat = format.dateFormat
        locale = format.locale
        timeZone = format.timeZone
    }
    
    public static func rfc1123DateFormatter() -> NSDateFormatter {
        return common.rfc1123DateFormatter
    }
    
    public static func rfc1123Date(fromString string: String) -> NSDate? {
        return common.rfc1123DateFormatter.dateFromString(string)
    }
    
    public static func rfc1123String(fromDate date: NSDate) -> String {
        return common.rfc1123DateFormatter.stringFromDate(date)
    }
}
