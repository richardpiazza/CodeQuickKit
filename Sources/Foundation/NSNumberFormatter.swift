//===----------------------------------------------------------------------===//
//
// NSNumberFormatter.swift
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

public enum NumberFormat {
    case Integer
    case SingleDecimal
    case Decimal
    case Currency
    case Percent
    
    var numberStyle: NSNumberFormatterStyle {
        switch self {
        case .Currency: return .CurrencyStyle
        case .Percent: return .PercentStyle
        default: return .DecimalStyle
        }
    }
    
    var minimumFractionDigits: Int {
        switch self {
        case .Percent: return 1
        default: return 0
        }
    }
    
    var maximumFractionDigits: Int {
        switch self {
        case .Integer: return 0
        case .SingleDecimal: return 1
        case .Decimal, .Currency: return 2
        case .Percent: return 4
        }
    }
    
    var locale: NSLocale {
        switch self {
        default: return NSLocale.currentLocale()
        }
    }
}

public extension NSNumberFormatter {
    private struct common {
        static let integerFormatter = NSNumberFormatter(withNumberFormat: .Integer)
        static let singleDecimalFormatter = NSNumberFormatter(withNumberFormat: .SingleDecimal)
        static let decimalFormatter = NSNumberFormatter(withNumberFormat: .Decimal)
        static let currencyFormatter = NSNumberFormatter(withNumberFormat: .Currency)
        static let percentFormatter = NSNumberFormatter(withNumberFormat: .Percent)
    }
    
    public convenience init(withNumberFormat format: NumberFormat) {
        self.init()
        numberStyle = format.numberStyle
        locale = format.locale
        minimumFractionDigits = format.minimumFractionDigits
        maximumFractionDigits = format.maximumFractionDigits
    }
    
    /// An NSNumberFormatter for whole integers.
    /// Uses the NSNumberFormatterDecimalStyle with MaximumFractionDigits set to
    /// 0 (zero).
    public static func integerFormatter() -> NSNumberFormatter {
        return common.integerFormatter
    }
    
    public static func integer(fromString string: String) -> Int? {
        return common.integerFormatter.numberFromString(string)?.integerValue
    }
    
    public static func string(fromInteger number: Int) -> String? {
        return common.integerFormatter.stringFromNumber(number)
    }
    
    /// An NSNumberFormatter for whole integers.
    /// Uses the NSNumberFormatterDecimalStyle with MaximumFractionDigits set to
    /// 1 (one).
    public static func singleDecimalFormatter() -> NSNumberFormatter {
        return common.singleDecimalFormatter
    }
    
    public static func singleDecimal(fromString string: String) -> Float? {
        return common.singleDecimalFormatter.numberFromString(string)?.floatValue
    }
    
    public static func string(fromSingleDecimal number: Float) -> String? {
        return common.singleDecimalFormatter.stringFromNumber(number)
    }
    
    /// An NSNumberFormatter for whole integers.
    /// Uses the NSNumberFormatterDecimalStyle with MaximumFractionDigits set to
    /// 2 (two).
    public static func decimalFormatter() -> NSNumberFormatter {
        return common.decimalFormatter
    }
    
    public static func decimal(fromString string: String) -> Float? {
        return common.decimalFormatter.numberFromString(string)?.floatValue
    }
    
    public static func string(fromDecimal number: Float) -> String? {
        return common.decimalFormatter.stringFromNumber(number)
    }
    
    /// An NSNumberFormatter for whole integers.
    /// Uses the NSNumberFormatterCurrencyStyle.
    public static func currencyFormatter() -> NSNumberFormatter {
        return common.currencyFormatter
    }
    
    public static func currency(fromString string: String) -> Float? {
        return common.currencyFormatter.numberFromString(string)?.floatValue
    }
    
    public static func string(fromCurrency number: Float) -> String? {
        return common.currencyFormatter.stringFromNumber(number)
    }
    
    /// An NSNumberFormatter for whole integers.
    /// Uses the NSNumberFormatterPercentStyle with MinimumFractionDigits set to
    /// 1 (one) and MaximumFractionDigits set to 3 (three).
    public static func percentFormatter() -> NSNumberFormatter {
        return common.percentFormatter
    }
    
    public static func percent(fromString string: String) -> Float? {
        return common.percentFormatter.numberFromString(string)?.floatValue
    }
    
    public static func string(fromPercent number: Float) -> String? {
        return common.percentFormatter.stringFromNumber(number)
    }
}
