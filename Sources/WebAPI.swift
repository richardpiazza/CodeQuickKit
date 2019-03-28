import Foundation

open class WebAPI: HTTPClient, HTTPCodable, HTTPInjectable {
    
    public var baseURL: URL
    public var session: URLSession
    public var authorization: HTTP.Authorization?
    public var jsonEncoder: JSONEncoder = JSONEncoder()
    public var jsonDecoder: JSONDecoder = JSONDecoder()
    public var injectedResponses: [InjectedPath : InjectedResponse] = [:]
    
    public var sessionConfiguration: URLSessionConfiguration = .default {
        didSet {
            resetSession()
        }
    }
    
    public var sessionDelegate: URLSessionDelegate? {
        didSet {
            resetSession()
        }
    }
    
    public init(baseURL: URL, session: URLSession? = nil, delegate: URLSessionDelegate? = nil) {
        self.baseURL = baseURL
        if let session = session {
            self.session = session
        } else {
            self.session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        }
        if let delegate = delegate {
            self.sessionDelegate = delegate
        }
    }
    
    private func resetSession() {
        session.invalidateAndCancel()
        session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
    }
}

public extension WebAPI {
    /// Transforms the request into a `multipart/form-data` request.
    /// The request `content-type` will be set to `image/png`
    func execute(method: HTTP.RequestMethod, path: String, queryItems: [URLQueryItem]?, pngImageData: Data, filename: String = "image.png", completion: @escaping HTTP.DataTaskCompletion) {
        var request: URLRequest
        do {
            request = try self.request(method: method, path: path, queryItems: queryItems, data: nil)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        let boundary = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: HTTP.Header.contentType.rawValue)
        
        var data = Data()
        
        if let d = "--\(boundary)\r\n".data(using: String.Encoding.utf8) {
            data.append(d)
        }
        if let d = "Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8) {
            data.append(d)
        }
        if let d = "Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8) {
            data.append(d)
        }
        data.append(pngImageData)
        if let d = "\r\n".data(using: String.Encoding.utf8) {
            data.append(d)
        }
        if let d = "--\(boundary)--\r\n".data(using: String.Encoding.utf8) {
            data.append(d)
        }
        
        let contentLength = String(format: "%zu", data.count)
        request.setValue(contentLength, forHTTPHeaderField: HTTP.Header.contentLength.rawValue)
        
        request.httpBody = data
        
        self.execute(request: request, completion: completion)
    }
}

/// A preconfigured URLSessionDelegate that will ignore invalid/self-signed SSL Certificates.
public class SelfSignedSessionDelegate: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.previousFailureCount < 1 else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        var credentials: URLCredential?
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                credentials = URLCredential(trust: serverTrust)
            }
        }
        
        completionHandler(.useCredential, credentials)
    }
}
