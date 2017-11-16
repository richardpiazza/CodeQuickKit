import Foundation

public typealias MetadataQueryResults = [String : Date]

public extension NSMetadataQuery {
    var nonHiddenDocuments: MetadataQueryResults {
        var documents = MetadataQueryResults()
        
        for item in results {
            guard let url = (item as AnyObject).value(forAttribute: NSMetadataItemURLKey) as? URL else {
                continue
            }
            
            var fileDate: Date? = (item as AnyObject).value(forAttribute: NSMetadataItemFSContentChangeDateKey) as? Date
            if fileDate == nil {
                fileDate = (item as AnyObject).value(forAttribute: NSMetadataItemFSCreationDateKey) as? Date
            }
            
            guard let date = fileDate else {
                continue
            }
            
            var isHidden: AnyObject?
            do {
                try (url as NSURL).getResourceValue(&isHidden, forKey: URLResourceKey.isHiddenKey)
            } catch {
                Log.error(error)
                continue
            }
            
            guard let isHiddenNumber = isHidden as? NSNumber , isHiddenNumber.boolValue == false else {
                continue
            }
            
            documents[url.absoluteString] = date
        }
        
        return documents
    }
}
