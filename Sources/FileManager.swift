import Foundation

public struct UbiquityDocuments {
    var documentPaths: [String]?
    var modifiedDocumentPaths: [String]?
    var removedDocumentPaths: [String]?
    var addedDocumentPaths: [String]?
}

public typealias UbiquityDocumentsCompletion = (_ documents: UbiquityDocuments?, _ error: Error?) -> Void

public class DocumentsUbiquityContainer: UbiquityContainer {
    public struct Keys {
        static let documents = "Documents"
    }
    
    override public var directory: URL? {
        didSet {
            guard let d = directory else {
                documentsDirectory = nil
                return
            }
            
            documentsDirectory = d.appendingPathComponent(DocumentsUbiquityContainer.Keys.documents)
        }
    }
    var documentsDirectory: URL?
    var documentPaths: [String] = [String]()
    var documentTimestamps: [String : Date] = [String : Date]()
    var documentQuery: NSMetadataQuery?
    var documentsCompletion: UbiquityDocumentsCompletion?
    
    @objc func nsMetadataQueryDidFinishGathering(_ notification: Notification) {
        guard let documentQuery = self.documentQuery else {
            return
        }
        
        documentQuery.disableUpdates()
        documentPaths.removeAll()
        documentTimestamps.removeAll()
        
        let nonHiddenDocuments = documentQuery.nonHiddenDocuments
        for (path, date) in nonHiddenDocuments {
            documentPaths.append(path)
            documentTimestamps[path] = date as Date
        }
        
        if let completion = documentsCompletion {
            var documents = UbiquityDocuments()
            documents.documentPaths = documentPaths
            completion(documents, nil)
        }
        
        documentQuery.enableUpdates()
    }
    
    @objc func nsMetadataQueryDidUpdate(_ notification: Notification) {
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
                documentTimestamps[path] = date as Date
                continue
            }
            
            guard let modifiedDate = documentTimestamps[path] else {
                modifiedDocuments.append(path)
                documentTimestamps[path] = date as Date
                continue
            }
            
            if modifiedDate == date as Date {
                unmodifiedDocuments.append(path)
            } else {
                modifiedDocuments.append(path)
            }
        }
        
        for (index, documentPath) in documentPaths.reversed().enumerated() {
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
            documentPaths.remove(at: index)
        }
        
        if let completion = documentsCompletion {
            let documents = UbiquityDocuments(documentPaths: unmodifiedDocuments, modifiedDocumentPaths: modifiedDocuments, removedDocumentPaths: removedDocuments, addedDocumentPaths: addedDocuments)
            completion(documents, nil)
        }
        
        documentQuery.enableUpdates()
    }
    
    public func ubiquityDocuments(withExtension ext: String?, completion: @escaping UbiquityDocumentsCompletion) {
        endUbiquityDocumentsQuery()
        
        guard ubiquityState == .available else {
            completion(nil, UbiquityError.invalidState)
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
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(DocumentsUbiquityContainer.nsMetadataQueryDidFinishGathering(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DocumentsUbiquityContainer.nsMetadataQueryDidUpdate(_:)), name: NSNotification.Name.NSMetadataQueryDidUpdate, object: nil)
        
        documentQuery.start()
    }
    
    public func endUbiquityDocumentsQuery() {
        guard let documentQuery = self.documentQuery else {
            return
        }
        
        documentQuery.stop()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSMetadataQueryDidUpdate, object: nil)
        self.documentQuery = nil
    }
}

public extension FileManager {
    
    var sandboxDirectory: URL? {
        guard let directory = self.sandboxDocumentsDirectory else {
            return nil
        }
        
        return directory.deletingLastPathComponent()
    }
    
    var sandboxDocumentsDirectory: URL? {
        let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let path = searchPath.last else {
            return nil
        }
        
        return URL(fileURLWithPath: path)
    }
    
    func sandboxDocuments(withExtension ext: String?) -> [URL] {
        return self.sandboxDocuments(atPath: nil, withExtension: ext)
    }
    
    func sandboxDocuments(atPath path: String?, withExtension ext: String?) -> [URL] {
        var urls: [URL] = [URL]()
        
        guard let documentsURL = self.sandboxDocumentsDirectory else {
            return urls
        }
        
        var documentsDirectory = documentsURL
        if let pathComponent = path {
            documentsDirectory = documentsURL.appendingPathComponent(pathComponent)
        }
        
        var allDocuments: [URL]?
        do {
            allDocuments = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        } catch {
            Log.error(error)
            return urls
        }
        
        guard allDocuments != nil else {
            return urls
        }
        
        guard ext != nil && ext != "" else {
            urls.append(contentsOf: allDocuments!)
            return urls
        }
        
        let pathExtension = (ext!.hasPrefix(".")) ? String(ext![ext!.index(ext!.startIndex, offsetBy: 1)..<ext!.endIndex]) : ext!
        
        for doc in allDocuments! {
            if doc.pathExtension == pathExtension {
                urls.append(doc)
            }
        }
        
        return urls
    }
    
    static var ubiquityContainer: DocumentsUbiquityContainer = DocumentsUbiquityContainer()
}
