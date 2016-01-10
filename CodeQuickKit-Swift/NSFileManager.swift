//===----------------------------------------------------------------------===//
//
// NSFileManger.swift
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

public extension NSFileManager {
    public var sandboxDirectory: NSURL? {
        guard let directory = self.sandboxDocumentsDirectory else {
            return nil
        }
        
        return directory.URLByDeletingLastPathComponent
    }
    
    public var sandboxDocumentsDirectory: NSURL? {
        let searchPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        guard let path = searchPath.last else {
            return nil
        }
        
        return NSURL(fileURLWithPath: path)
    }
    
    public func sandboxDocuments(withExtension ext: String?) -> [NSURL] {
        return self.sandboxDocuments(atPath: nil, withExtension: ext)
    }
    
    public func sandboxDocuments(atPath path: String?, withExtension ext: String?) -> [NSURL] {
        var urls: [NSURL] = [NSURL]()
        
        guard let documentsURL = self.sandboxDocumentsDirectory else {
            return urls
        }
        
        var documentsDirectory = documentsURL
        if let pathComponent = path {
            documentsDirectory = documentsURL.URLByAppendingPathComponent(pathComponent)
        }
        
        var allDocuments: [NSURL]?
        do {
            allDocuments = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsDirectory, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
        } catch {
            Logger.logError(withError: (error as NSError), message: "contentsOfDirectoryAtURL failed")
            return urls
        }
        
        guard allDocuments != nil else {
            return urls
        }
        
        guard ext != nil && ext != "" else {
            urls.appendContentsOf(allDocuments!)
            return urls
        }
        
        let pathExtension = (ext!.hasPrefix(".")) ? ext!.substringFromIndex(ext!.startIndex.advancedBy(1)) : ext!
        
        for doc in allDocuments! {
            if doc.pathExtension == pathExtension {
                urls.append(doc)
            }
        }
        
        return urls
    }
}
