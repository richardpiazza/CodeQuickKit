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

public extension NSNumberFormatter {
    /// An NSNumberFormatter for whole integers.
    /// Uses the NSNumberFormatterDecimalStyle with MaximumFractionDigits set to
    /// 0 (zero).
    public static var integerFormatter: NSNumberFormatter {
        return NSNumberFormatter(numberStyle: .DecimalStyle, maximumFractionDigits: 0)
    }
    
    public static func integerFromString(string: String) -> Int? {
        return integerFormatter.numberFromString(string)?.integerValue
    }
    
    public static func integerStringFromNumber(number: Int) -> String? {
        return integerFormatter.stringFromNumber(number)
    }
    
    /// An NSNumberFormatter for whole integers.
    /// Uses the NSNumberFormatterDecimalStyle with MaximumFractionDigits set to
    /// 1 (one).
    public static var singleDecimalFormatter: NSNumberFormatter {
        return NSNumberFormatter(numberStyle: .DecimalStyle, maximumFractionDigits: 1)
    }
    
    public static func singleDecimalFromString(string: String) -> Int? {
        return singleDecimalFormatter.numberFromString(string)?.integerValue
    }
    
    public static func singleDecimalStringFromNumber(number: Int) -> String? {
        return singleDecimalFormatter.stringFromNumber(number)
    }
    
    /// An NSNumberFormatter for whole integers.
    /// Uses the NSNumberFormatterDecimalStyle with MaximumFractionDigits set to
    /// 2 (two).
    public static var decimalFormatter: NSNumberFormatter {
        return NSNumberFormatter(numberStyle: .DecimalStyle, maximumFractionDigits: 2)
    }
    
    public static func decimalFromString(string: String) -> Int? {
        return decimalFormatter.numberFromString(string)?.integerValue
    }
    
    public static func decimalStringFromNumber(number: Int) -> String? {
        return decimalFormatter.stringFromNumber(number)
    }
    
    /// An NSNumberFormatter for whole integers.
    /// Uses the NSNumberFormatterCurrencyStyle.
    public static var currencyFormatter: NSNumberFormatter {
        return NSNumberFormatter(numberStyle: .CurrencyStyle, locale: NSLocale.currentLocale())
    }
    
    public static func currencyFromString(string: String) -> Int? {
        return currencyFormatter.numberFromString(string)?.integerValue
    }
    
    public static func currencyStringFromNumber(number: Int) -> String? {
        return currencyFormatter.stringFromNumber(number)
    }
    
    /// An NSNumberFormatter for whole integers.
    /// Uses the NSNumberFormatterPercentStyle with MinimumFractionDigits set to
    /// 1 (one) and MaximumFractionDigits set to 3 (three).
    public static var percentFormatter: NSNumberFormatter {
        return NSNumberFormatter(numberStyle: .DecimalStyle, minimumFractionDigits: 1, maximumFractionDigits: 3)
    }
    
    public static func percentFromString(string: String) -> Int? {
        return percentFormatter.numberFromString(string)?.integerValue
    }
    
    public static func percentStringFromNumber(number: Int) -> String? {
        return percentFormatter.stringFromNumber(number)
    }
    
    convenience init(numberStyle: NSNumberFormatterStyle, maximumFractionDigits: Int) {
        self.init()
        self.numberStyle = numberStyle
        self.maximumFractionDigits = maximumFractionDigits
    }
    
    convenience init(numberStyle: NSNumberFormatterStyle, minimumFractionDigits: Int, maximumFractionDigits: Int) {
        self.init()
        self.numberStyle = numberStyle
        self.minimumFractionDigits = minimumFractionDigits
        self.maximumFractionDigits = maximumFractionDigits
    }
    
    convenience init(numberStyle: NSNumberFormatterStyle, locale: NSLocale) {
        self.init()
        self.numberStyle = numberStyle
        self.locale = locale
    }
}
