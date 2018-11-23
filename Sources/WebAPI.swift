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
