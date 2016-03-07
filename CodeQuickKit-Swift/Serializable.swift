//===----------------------------------------------------------------------===//
//
// Serializable.swift
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

public typealias SerializableDictionary = [String : NSObject]

public protocol Serializable: NSObjectProtocol {
    func setDefaults()
    
    init(withDictionary dictionary: SerializableDictionary?)
    func update(withDictionary dictionary: SerializableDictionary?)
    var dictionary: SerializableDictionary { get }
    
    init(withData data: NSData?)
    func update(withData data: NSData?)
    var data: NSData? { get }
    
    init(withJSON json: String?)
    func update(withJSON json: String?)
    var json: String? { get }
    
    func propertyName(forSerializedKey serializedKey: String) -> String?
    func serializedKey(forPropertyName propertyName: String) -> String?
    func initializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject?
    func serializedObject(forPropertyName propertyname: String, withData data: NSObject) -> NSObject?
    func objectClassOfCollectionType(forPropertyname propertyName: String) -> AnyClass?
}

public extension Serializable {
    static func initializeSerializable(withDictionary dictionary: SerializableDictionary?) -> Self {
        return self.init(withDictionary: dictionary)
    }
    
    static func initializeSerializable(withData data: NSData?) -> Self {
        return self.init(withData: data)
    }
    
    static func initializeSerializable(withJSON json: String?) -> Self {
        return self.init(withJSON: json)
    }
}
