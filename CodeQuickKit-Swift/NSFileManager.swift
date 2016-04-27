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

public struct UbiquityDocuments {
    var documentPaths: [String]?
    var modifiedDocumentPaths: [String]?
    var removedDocumentPaths: [String]?
    var addedDocumentPaths: [String]?
}

public typealias UbiquityDocumentsCompletion = (documents: UbiquityDocuments?, error: NSError?) -> Void

public class DocumentsUbiquityContainer: UbiquityContainer {
    public struct Keys {
        static let documents = "Documents"
    }
    
    override public var directory: NSURL? {
        didSet {
            guard let d = directory else {
                documentsDirectory = nil
                return
            }
            
            documentsDirectory = d.URLByAppendingPathComponent(DocumentsUbiquityContainer.Keys.documents)
        }
    }
    var documentsDirectory: NSURL?
    var documentPaths: [String] = [String]()
    var documentTimestamps: [String : NSDate] = [String : NSDate]()
    var documentQuery: NSMetadataQuery?
    var documentsCompletion: UbiquityDocumentsCompletion?
    
    @objc func nsMetadataQueryDidFinishGathering(notification: NSNotification) {
        guard let documentQuery = self.documentQuery else {
            return
        }
        
        documentQuery.disableUpdates()
        documentPaths.removeAll()
        documentTimestamps.removeAll()
        
        let nonHiddenDocuments = documentQuery.nonHiddenDocuments
        for (path, date) in nonHiddenDocuments {
            documentPaths.append(path)
            documentTimestamps[path] = date
        }
        
        if let completion = documentsCompletion {
            var documents = UbiquityDocuments()
            documents.documentPaths = documentPaths
            completion(documents: documents, error: nil)
        }
        
        documentQuery.enableUpdates()
    }
    
    @objc func nsMetadataQueryDidUpdate(notification: NSNotification) {
        guard let documentQuery = self.documentQuery else {
            return
        }
        
        documentQuery.disableUpdates()
        
        var unmodifiedDocuments = [String]()
        var modifiedDocuments = [String]()
        var removedDocuments = [String]()
        var addedDocuments = [String]()
        
        let nonHiddenDocuments = documentQuery.nonHiddenDocuments
        for (path, date) in nonHiddenDocuments {
            var found = false
            
            for existingPath in self.documentPaths {
                if existingPath == path {
                    found = true
                }
            }
            
            guard found else {
                addedDocuments.append(path)
                documentPaths.append(path)
                documentTimestamps[path] = date
                continue
            }
            
            guard let modifiedDate = documentTimestamps[path] else {
                modifiedDocuments.append(path)
                documentTimestamps[path] = date
                continue
            }
            
            if modifiedDate == date {
                unmodifiedDocuments.append(path)
            } else {
                modifiedDocuments.append(path)
            }
        }
        
        for (index, documentPath) in documentPaths.reverse().enumerate() {
            var found = false
            
            for (path, _) in nonHiddenDocuments {
                if path == documentPath {
                    found = true
                }
            }
            
            guard found == false else {
                continue
            }
            
            removedDocuments.append(documentPath)
            documentTimestamps[documentPath] = nil
            documentPaths.removeAtIndex(index)
        }
        
        if let completion = documentsCompletion {
            let documents = UbiquityDocuments(documentPaths: unmodifiedDocuments, modifiedDocumentPaths: modifiedDocuments, removedDocumentPaths: removedDocuments, addedDocumentPaths: addedDocuments)
            completion(documents: documents, error: nil)
        }
        
        documentQuery.enableUpdates()
    }
    
    public func ubiquityDocuments(withExtension ext: String?, completion: UbiquityDocumentsCompletion) {
        endUbiquityDocumentsQuery()
        
        guard ubiquityState == .Available else {
            completion(documents: nil, error: UbiquityState.invalidUbiquityState)
            return
        }
        
        self.documentsCompletion = completion
        self.documentQuery = NSMetadataQuery()
        guard let documentQuery = self.documentQuery else {
            return
        }
        
        documentQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        if let ext = ext {
            var filePattern: String
            if ext.hasPrefix(".") {
                filePattern = "*\(ext)"
            } else {
                filePattern = "*.\(ext)"
            }
            documentQuery.predicate = NSPredicate(format: "%K LIKE %@", argumentArray: [filePattern])
        } else {
            documentQuery.predicate = NSPredicate(format: "%K == *", argumentArray: [NSMetadataItemFSNameKey])
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocumentsUbiquityContainer.nsMetadataQueryDidFinishGathering(_:)), name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocumentsUbiquityContainer.nsMetadataQueryDidUpdate(_:)), name: NSMetadataQueryDidUpdateNotification, object: nil)
        
        documentQuery.startQuery()
    }
    
    public func endUbiquityDocumentsQuery() {
        guard let documentQuery = self.documentQuery else {
            return
        }
        
        documentQuery.stopQuery()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidUpdateNotification, object: nil)
        self.documentQuery = nil
    }
}

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
            Logger.error((error as NSError), message: "contentsOfDirectoryAtURL failed")
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
    
    public static var ubiquityContainer: DocumentsUbiquityContainer = DocumentsUbiquityContainer()
}
