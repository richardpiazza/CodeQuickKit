import Foundation

public typealias DataTaskCompletion = (_ statusCode: Int, _ headers: HTTP.Headers?, _ data: Data?, _ error: Error?) -> Void

/// A wrapper for URLSession meant for interacting with JSON REST API's.
open class WebAPI {
    
    public enum Error: Swift.Error, LocalizedError {
        case invalidURL
        case invalidRequest
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid Base URL: Base URL is nil or invalid"
            case .invalidRequest: return "Invalid URL Request: URLRequest is nil or invalid"
            }
        }
    }
    
    /// The root URL used to construct all queries.
    public var baseURL: URL?
    /// Canned responses used to mock the API calls.
    public var injectedResponses: [InjectedPath : InjectedResponse] = [InjectedPath : InjectedResponse]()
    /// Decoder used to automatically decode `Codable` data types.
    open var jsonDecoder: JSONDecoder = JSONDecoder()
    /// Encoder used to automatically encode `Codable` data types.
    open var jsonEncoder: JSONEncoder = JSONEncoder()
    /// Basic Auth credentials to provide in the request headers.
    public var credentials: HTTP.Credentials?
    /// Bearer Auth token to provide in the request headers.
    /// - note: Takes precedence over `credentials`
    public var bearerToken: String?
    
    public var sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default {
        didSet {
            invalidateSession()
        }
    }
    public var sessionDelegate: URLSessionDelegate? {
        didSet {
            invalidateSession()
        }
    }
    lazy public var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration, delegate: self.sessionDelegate, delegateQueue: nil)
    }()
    
    public init(baseURL: URL, configuration: URLSessionConfiguration? = nil, delegate: URLSessionDelegate? = nil) {
        self.baseURL = baseURL
        if let configuration = configuration {
            self.sessionConfiguration = configuration
        }
        if let delegate = delegate {
            self.sessionDelegate = delegate
        }
    }
    
    private func invalidateSession() {
        session.invalidateAndCancel()
        session = URLSession(configuration: self.sessionConfiguration, delegate: self.sessionDelegate, delegateQueue: nil)
    }
    
    // MARK: - Request Setup
    
    /// Constructs the request, setting the method, body data, and headers based on parameters
    /// Subclasses can override this method to customize the request as needed.
    open func request(method: HTTP.RequestMethod, path: String, queryItems: [URLQueryItem]?, data: Data?) throws -> URLRequest {
        guard let baseURL = self.baseURL else {
            throw Error.invalidURL
        }
        
        var urlWithComponents = URLComponents(string: baseURL.appendingPathComponent(path).absoluteString)
        urlWithComponents?.queryItems = queryItems
        
        guard let url = urlWithComponents?.url else {
            throw Error.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let data = data {
            request.httpBody = data
            request.setValue("\(data.count)", forHTTPHeaderField: HTTP.Header.contentLength.rawValue)
        }
        request.setValue(HTTP.Header.dateFormatter.string(from: Date()), forHTTPHeaderField: HTTP.Header.date.rawValue)
        request.setValue(HTTP.MIMEType.applicationJson.rawValue, forHTTPHeaderField: HTTP.Header.accept.rawValue)
        request.setValue(HTTP.MIMEType.applicationJson.rawValue, forHTTPHeaderField: HTTP.Header.contentType.rawValue)
        
        if let credentials = self.credentials {
            let username = credentials.username
            let password = credentials.password ?? ""
            if let data = "\(username):\(password)".data(using: .utf8) {
                let base64 = data.base64EncodedString(options: [])
                let headerValue = "\(HTTP.Authorization.basic.rawValue) \(base64)"
                request.setValue(headerValue, forHTTPHeaderField: HTTP.Header.authorization.rawValue)
            }
        }
        
        if let bearerToken = self.bearerToken {
            let headerValue = "\(HTTP.Authorization.bearer.rawValue) \(bearerToken)"
            request.setValue(headerValue, forHTTPHeaderField: HTTP.Header.authorization.rawValue)
        }
        
        return request
    }
    
    // MARK: - Execution
    
    /// Executes the specified request.
    /// - note: Injected Responses will be queried before a task is created and executed.
    open func execute(request: URLRequest, completion: @escaping DataTaskCompletion) {
        guard let _ = request.url else {
            completion(0, nil, nil, Error.invalidURL)
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
    
    /// Creates a URLSessionDataTask using the URLSession.
    open func task(request: URLRequest, completion: @escaping DataTaskCompletion) -> URLSessionDataTask {
        return session.dataTask(with: request, completionHandler: { (responseData, urlResponse, error) in
            guard let response = urlResponse else {
                completion(0, nil, responseData, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(0, nil, responseData, error)
                return
            }
            
            completion(httpResponse.statusCode, httpResponse.allHeaderFields, responseData, error)
        })
    }
    
    // MARK: - Convenience Execution
    
    public final func get(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping DataTaskCompletion) {
        do {
            let request = try self.request(method: .get, path: path, queryItems: queryItems, data: nil)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    public final func put(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping DataTaskCompletion) {
        do {
            let request = try self.request(method: .put, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    public final func post(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping DataTaskCompletion) {
        do {
            let request = try self.request(method: .post, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    public final func patch(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping DataTaskCompletion) {
        do {
            let request = try self.request(method: .patch, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    public final func delete(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping DataTaskCompletion) {
        do {
            let request = try self.request(method: .delete, path: path, queryItems: queryItems, data: nil)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
}
