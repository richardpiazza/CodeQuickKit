//===----------------------------------------------------------------------===//
//
// String.swift
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

// MARK: - Serializable
extension String: Serializable {}

public extension String {
    public func stringByApplyingKeyStyle(keyStyle: SerializerKeyStyle) -> String {
        guard self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 1 else {
            return self
        }
        
        switch (keyStyle) {
        case .TitleCase:
            let range: Range = Range<String.Index>(start: self.startIndex, end: self.startIndex.advancedBy(1))
            let string = self.substringWithRange(range).uppercaseString
            return self.stringByReplacingCharactersInRange(range, withString: string)
        case .CamelCase:
            let range: Range = Range<String.Index>(start: self.startIndex, end: self.startIndex.advancedBy(1))
            let string = self.substringWithRange(range).lowercaseString
            return self.stringByReplacingCharactersInRange(range, withString: string)
        case .UpperCase: return self.uppercaseString
        case .LowerCase: return self.lowercaseString
        default: return self
        }
    }
    
    public var stringByRemovingPrettyJSONFormatting: String {
        let string: NSMutableString = NSMutableString(string: self)
        string.replaceOccurrencesOfString("\n", withString: "", options: .CaseInsensitiveSearch, range: NSMakeRange(0, string.length))
        string.replaceOccurrencesOfString(" : ", withString: ":", options: .CaseInsensitiveSearch, range: NSMakeRange(0, string.length))
        string.replaceOccurrencesOfString("  ", withString: "", options: .CaseInsensitiveSearch, range: NSMakeRange(0, string.length))
        string.replaceOccurrencesOfString("\\/", withString: "/", options: .CaseInsensitiveSearch, range: NSMakeRange(0, string.length))
        return string as String
    }
}
