import Foundation

public typealias WebAPIRequestCompletion = (_ statusCode: Int, _ headers: [AnyHashable : Any]?, _ data: Data?, _ error: Error?) -> Void

/// # WebAPI
/// A testable wrapper for URLSession for communication with REST API's
open class WebAPI {
    
    public enum HTTPRequestMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    public struct HTTPHeaderKey {
        public static let Accept = "Accept"
        public static let Authorization = "Authorization"
        public static let ContentLength = "Content-Length"
        public static let ContentMD5 = "Content-MD5"
        public static let ContentType = "Content-Type"
        public static let Date = "Date"
    }
    
    public struct HTTPHeaderValue {
        public static let ApplicationJson = "application/json"
        public static let ImagePNG = "image/png"
    }
    
    public struct InjectedPath: Hashable {
        var method: HTTPRequestMethod = .get
        var absoluteString: String
        
        public init(request: URLRequest) {
            var m = HTTPRequestMethod.get
            if let httpMethod = request.httpMethod, let requestMethod = HTTPRequestMethod(rawValue: httpMethod) {
                m = requestMethod
            }
            var a = ""
            if let url = request.url {
                a = url.absoluteString
            }
            self.init(method: m, string: a)
        }
        
        public init(string: String) {
            self.init(method: .get, string: string)
        }
        
        public init(method: HTTPRequestMethod, string: String) {
            self.method = method
            self.absoluteString = string
        }
        
        public var hashValue: Int {
            return "\(method.rawValue)\(absoluteString)".hashValue
        }
        
        public static func ==(lhs: InjectedPath, rhs: InjectedPath) -> Bool {
            guard lhs.method == rhs.method else {
                return false
            }
            
            guard lhs.absoluteString == rhs.absoluteString else {
                return false
            }
            
            return true
        }
    }
    
    public struct InjectedResponse {
        public var statusCode: Int = 0
        public var headers: [AnyHashable : Any]?
        public var data: Data?
        public var error: Error?
        public var timeout: UInt64 = 0
        
        public init() {
        }
        
        public init(statusCode: Int, headers: [AnyHashable : Any]? = nil, data: Data? = nil, error: Error? = nil, timeout: UInt64 = 0) {
            self.statusCode = statusCode
            self.headers = headers
            self.data = data
            self.error = error
            self.timeout = timeout
        }
    }
    
    public enum Errors: Error {
        case invalidURL
        case invalidRequest
        
        public var localizedDescription: String {
            switch self {
            case .invalidURL: return "Invalid Base URL: Base URL is nil or invalid"
            case .invalidRequest: return "Invalid URL Request: URLRequest is nil or invalid"
            }
        }
    }
    
    public var baseURL: URL?
    public var injectedResponses: [InjectedPath : InjectedResponse] = [InjectedPath : InjectedResponse]()
    public var sessionDelegate: URLSessionDelegate?
    public lazy var session: URLSession = {
        [unowned self] in
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self.sessionDelegate, delegateQueue: nil)
    }()
    
    public init(baseURL: URL?, sessionDelegate: URLSessionDelegate?) {
        self.baseURL = baseURL
        self.sessionDelegate = sessionDelegate
    }
    
    // MARK: - Request Setup
    
    /// Constructs the request, setting the method, body data, and headers based on parameters
    /// Subclasses can override this method to customize the request as needed.
    open func request(method: HTTPRequestMethod, path: String, queryItems: [URLQueryItem]?, data: Data?) throws -> URLRequest {
        guard let baseURL = self.baseURL else {
            Log.error(Errors.invalidURL)
            throw Errors.invalidURL
        }
        
        var urlWithComponents = URLComponents(string: baseURL.appendingPathComponent(path).absoluteString)
        urlWithComponents?.queryItems = queryItems
        
        guard let url = urlWithComponents?.url else {
            Log.error(Errors.invalidURL)
            throw Errors.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = data
        request.setValue(DateFormatter.rfc1123DateFormatter.string(from: Date()), forHTTPHeaderField: HTTPHeaderKey.Date)
        request.setValue(HTTPHeaderValue.ApplicationJson, forHTTPHeaderField: HTTPHeaderKey.Accept)
        request.setValue(HTTPHeaderValue.ApplicationJson, forHTTPHeaderField: HTTPHeaderKey.ContentType)
        
        return request
    }
    
    // MARK: - Task
    
    /// Constructs the URLSession task with the specified request
    /// - note: Injected Responses are ignored when using this method.
    open func task(request: URLRequest, completion: @escaping WebAPIRequestCompletion) -> URLSessionDataTask {
        return self.session.dataTask(with: request, completionHandler: { (responseData, urlResponse, error) in
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                Log.error(error, message: "URLResponse failed to cast as HTTPURLResponse")
                completion(0, nil, responseData, error)
                return
            }
            
            completion(httpResponse.statusCode, httpResponse.allHeaderFields, responseData, error)
        })
    }
        
    // MARK: - Execution
    
    /// Executes the specified request.
    /// - note: Injected Responses will be queried before a task is executed.
    open func execute(request: URLRequest, completion: @escaping WebAPIRequestCompletion) {
        guard let _ = request.url else {
            Log.error(Errors.invalidURL, message: "Failed to execute URL Request.")
            completion(0, nil, nil, Errors.invalidURL)
            return
        }
        
        if let canned = injectedResponses[InjectedPath(request: request)] {
            #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(canned.timeout * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                    completion(canned.statusCode, canned.headers, canned.data, canned.error)
                })
            #else
                let _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: canned.timeout) ?? TimeInterval(floatLiteral: 0.0), repeats: false, block: { (timer) in
                    completion(canned.statusCode, canned.headers, canned.data, canned.error)
                })
            #endif
            return
            
        }
        
        let task = self.task(request: request, completion: completion)
        task.resume()
    }
    
    /// Transforms the request into a `multipart/form-data` request.
    /// The request `content-type` will be set to `image/png`
    open func execute(method: HTTPRequestMethod, path: String, queryItems: [URLQueryItem]?, pngImageData: Data, filename: String = "image.png", completion: @escaping WebAPIRequestCompletion) {
        var request: URLRequest
        do {
            request = try self.request(method: method, path: path, queryItems: queryItems, data: nil)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        let boundary = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: HTTPHeaderKey.ContentType)
        
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
        request.setValue(contentLength, forHTTPHeaderField: HTTPHeaderKey.ContentLength)
        
        request.httpBody = data
        
        self.execute(request: request, completion: completion)
    }
    
    // MARK: - Convenience Execution
    
    public final func get(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping WebAPIRequestCompletion) {
        do {
            let request = try self.request(method: .get, path: path, queryItems: queryItems, data: nil)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    public final func put(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping WebAPIRequestCompletion) {
        do {
            let request = try self.request(method: .put, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    public final func post(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping WebAPIRequestCompletion) {
        do {
            let request = try self.request(method: .post, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    public final func delete(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping WebAPIRequestCompletion) {
        do {
            let request = try self.request(method: .delete, path: path, queryItems: queryItems, data: nil)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
}
