import Foundation

/// A Collection of HTTP methods/headers/values
public struct HTTP {
    
    /// HTTP defines a set of request methods to indicate the desired action to be performed for a given resource.
    /// Although they can also be nouns, these request methods are sometimes referred as HTTP verbs.
    public enum RequestMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
        
        public var description: String {
            switch self {
            case .get: return "The GET method requests a representation of the specified resource. Requests using GET should only retrieve data."
            case .put: return "The PUT method replaces all current representations of the target resource with the request payload."
            case .post: return "The POST method is used to submit an entity to the specified resource, often causing a change in state or side effects on the server."
            case .patch: return "The PATCH method is used to apply partial modifications to a resource."
            case .delete: return "The DELETE method deletes the specified resource."
            }
        }
    }
    
    /// HTTP Headers as provided from HTTPURLResponse
    public typealias Headers = [AnyHashable : Any]
    
    /// Command HTTP Header
    public enum Header: String {
        case accept = "Accept"
        case authorization = "Authorization"
        case contentLength = "Content-Length"
        case contentMD5 = "Content-MD5"
        case contentType = "Content-Type"
        case date = "Date"
        
        public var description: String {
            switch self {
            case .accept: return "The Accept request HTTP header advertises which content types, expressed as MIME types, the client is able to understand."
            case .authorization: return "The HTTP Authorization request header contains the credentials to authenticate a user agent with a server, usually after the server has responded with a 401 Unauthorized status and the WWW-Authenticate header."
            case .contentLength: return "The Content-Length entity header is indicating the size of the entity-body, in bytes, sent to the recipient."
            case .contentType: return "The Content-Type entity header is used to indicate the media type of the resource."
            case .contentMD5: return "The Content-MD5 header, may be used as a message integrity check (MIC), to verify that the decoded data are the same data that were initially sent."
            case .date: return "The Date general HTTP header contains the date and time at which the message was originated."
            }
        }
        
        /// HTTP Header date formatter; RFC1123
        public static var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
            formatter.timeZone = TimeZone.gmt
            formatter.locale = Locale.enUSPosix
            return formatter
        }()
    }
    
    /// MIME Types used in the API
    public enum MIMEType: String {
        case applicationJson = "application/json"
    }
    
    /// Common username/password pairing.
    public typealias Credentials = (username: String, password: String?)
    
    /// Authorization schemes used in the API
    public enum Authorization: String {
        case basic = "Basic"
        case bearer = "Bearer"
    }
}
