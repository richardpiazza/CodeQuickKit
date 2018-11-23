import Foundation

/// Protocol used to extend an `HTTPDataClient` with support for
/// injecting and retrieving canned responses.
public protocol HTTPInjectable {
    var injectedResponses: [InjectedPath : InjectedResponse] { get set }
}

public extension HTTPInjectable where Self: HTTPClient {
    public func execute(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion) {
        let injectedPath = InjectedPath(request: request)
        
        guard let injectedResponse = injectedResponses[injectedPath] else {
            completion(0, nil, nil, HTTP.Error.invalidResponse)
            return
        }
        
        #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(injectedResponse.timeout * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
            completion(injectedResponse.statusCode, injectedResponse.headers, injectedResponse.data, injectedResponse.error)
        })
        #else
        let _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: injectedResponse.timeout) ?? TimeInterval(floatLiteral: 0.0), repeats: false, block: { (timer) in
            completion(injectedResponse.statusCode, injectedResponse.headers, injectedResponse.data, injectedResponse.error)
        })
        #endif
    }
}

/// A Hashable compound type based on the method and absolute path of
/// a URLRequest.
public struct InjectedPath: Hashable {
    var method: HTTP.RequestMethod = .get
    var absolutePath: String
    
    public init(request: URLRequest) {
        var m = HTTP.RequestMethod.get
        if let httpMethod = request.httpMethod, let requestMethod = HTTP.RequestMethod(rawValue: httpMethod) {
            m = requestMethod
        }
        var a = ""
        if let url = request.url {
            a = url.absoluteString
        }
        self.init(method: m, absolutePath: a)
    }
    
    public init(string: String) {
        self.init(method: .get, absolutePath: string)
    }
    
    public init(method: HTTP.RequestMethod, absolutePath: String) {
        self.method = method
        self.absolutePath = absolutePath
    }
    
    public var hashValue: Int {
        return "\(method.rawValue)\(absolutePath)".hashValue
    }
    
    public static func ==(lhs: InjectedPath, rhs: InjectedPath) -> Bool {
        guard lhs.method == rhs.method else {
            return false
        }
        
        guard lhs.absolutePath == rhs.absolutePath else {
            return false
        }
        
        return true
    }
}

/// A response to provide for a pre-determinied request.
public struct InjectedResponse {
    public var statusCode: Int = 0
    public var headers: HTTP.Headers?
    public var data: Data?
    public var error: Error?
    public var timeout: UInt64 = 0
    
    public init() {
    }
    
    public init(statusCode: Int, headers: HTTP.Headers? = nil, data: Data? = nil, error: Error? = nil, timeout: UInt64 = 0) {
        self.statusCode = statusCode
        self.headers = headers
        self.data = data
        self.error = error
        self.timeout = timeout
    }
}
