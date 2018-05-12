import Foundation

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
