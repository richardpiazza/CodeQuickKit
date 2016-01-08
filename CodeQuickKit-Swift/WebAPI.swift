//===----------------------------------------------------------------------===//
//
// WebAPI.swift
//
// Copyright (c) 2016 Richard Piazza
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

public typealias WebAPICompletion = (statusCode: Int, responseObject: AnyObject?, error: NSError?) -> Void

public enum WebAPIRequestMethod {
    case Get
    case Put
    case Post
    case Delete
    
    func httpMethod() -> String {
        switch self {
        case .Get: return "GET"
        case .Put: return "PUT"
        case .Post: return "POST"
        case .Delete: return "DELETE"
        }
    }
}

public class WebAPI {
    static let AcceptHeaderKey = "Accept"
    static let DateHeaderKey = "Date"
    static let ContentTypeHeaderKey = "Content-Type"
    static let ContentMD5HeaderKey = "Content-MD5"
    static let ContentLengthHeaderKey = "Content-Length"
    static let AuthorizationHeaderKey = "Authorization"
    static let ApplicationJsonHeaderValue = "application/json"
    
    static var invalidURL: NSError = {
        let info: [String: AnyObject] = [NSLocalizedDescriptionKey:"Invalid Base URL",
            NSLocalizedFailureReasonErrorKey:"Base URL is nil or invalid",
            NSLocalizedRecoverySuggestionErrorKey:"Set the base URL and try the request again."]
        return NSError(domain: "WebAPI", code: 0, userInfo: info)
    }()
    
    static var invalidRequest: NSError = {
        let info: [String: AnyObject] = [NSLocalizedDescriptionKey:"Invalid URL Request",
            NSLocalizedFailureReasonErrorKey:"NSURLRequest is nil or invalid",
            NSLocalizedRecoverySuggestionErrorKey:"Try the request again with a valid NSURLRequest."]
        return NSError(domain: "WebAPI", code: 0, userInfo: info)
    }()
    
    public var baseURL: NSURL?
    public var injectedResponses: [String : WebAPIInjectedResponse] = [String : WebAPIInjectedResponse]()
    public var sessionDelegate: NSURLSessionDelegate?
    private lazy var session: NSURLSession = {
        [unowned self] in
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: configuration, delegate: self.sessionDelegate, delegateQueue: nil)
    }()
    
    public init() {
    }
    
    public convenience init(baseURL: NSURL?, sessionDelegate: NSURLSessionDelegate?) {
        self.init()
        self.baseURL = baseURL
        self.sessionDelegate = sessionDelegate
    }
    
    public func get(path: String, queryItems: [NSURLQueryItem]?, completion: WebAPICompletion) {
        self.execute(path, queryItems: queryItems, method: .Get, data: nil, completion: completion)
    }
    
    public func put(data: NSData?, path: String, queryItems: [NSURLQueryItem]?, completion: WebAPICompletion) {
        self.execute(path, queryItems: queryItems, method: .Put, data: data, completion: completion)
    }
    
    public func post(data: NSData?, path: String, queryItems: [NSURLQueryItem]?, completion: WebAPICompletion) {
        self.execute(path, queryItems: queryItems, method: .Post, data: data, completion: completion)
    }
    
    public func delete(path: String, queryItems: [NSURLQueryItem]?, completion: WebAPICompletion) {
        self.execute(path, queryItems: queryItems, method: .Delete, data: nil, completion: completion)
    }
    
    public func requestFor(path: String, queryItems: [NSURLQueryItem]?, method: WebAPIRequestMethod, data: NSData?) -> NSMutableURLRequest? {
        guard let baseURL = self.baseURL else {
            return nil
        }
        
        let urlWithComponents = NSURLComponents(string: baseURL.URLByAppendingPathComponent(path).absoluteString)
        urlWithComponents?.queryItems = queryItems
        
        guard let url = urlWithComponents?.URL else {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.httpMethod()
        request.HTTPBody = data
        request.setValue(NSDateFormatter.rfc1123DateFormatter.stringFromDate(NSDate()), forHTTPHeaderField: WebAPI.DateHeaderKey)
        request.setValue(WebAPI.ApplicationJsonHeaderValue, forHTTPHeaderField: WebAPI.AcceptHeaderKey)
        request.setValue(WebAPI.ApplicationJsonHeaderValue, forHTTPHeaderField: WebAPI.ContentTypeHeaderKey)
        
        return request
    }
    
    private func execute(path: String, queryItems: [NSURLQueryItem]?, method: WebAPIRequestMethod, data: NSData?, completion: WebAPICompletion) {
        if let request = self.requestFor(path, queryItems: queryItems, method: method, data: data) {
            self.execute(request, completion: completion)
        } else {
            completion(statusCode: 0, responseObject: nil, error: WebAPI.invalidRequest)
        }
    }
    
    private func execute(request: NSMutableURLRequest, completion: WebAPICompletion) {
        guard let url = request.URL else {
            completion(statusCode: 0, responseObject: nil, error: WebAPI.invalidRequest)
            return
        }
        
        if let canned = injectedResponses[url.absoluteString] {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(canned.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                completion(statusCode: canned.statusCode, responseObject: canned.responseObject, error: canned.error)
            })
            return
        }
        
        session.dataTaskWithRequest(request) { (responseData: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard error == nil else {
                    completion(statusCode: 0, responseObject: nil, error: error)
                    return
                }
                
                let httpResponse = response as! NSHTTPURLResponse
                
                guard let data = responseData else {
                    completion(statusCode: httpResponse.statusCode, responseObject: nil, error: error)
                    return
                }
                
                guard data.length != 0 else {
                    completion(statusCode: httpResponse.statusCode, responseObject: nil, error: error)
                    return
                }
                
                if let contentType = httpResponse.allHeaderFields[WebAPI.ContentTypeHeaderKey] {
                    guard contentType.hasPrefix(WebAPI.ApplicationJsonHeaderValue) else {
                        completion(statusCode: httpResponse.statusCode, responseObject: nil, error: error)
                        return
                    }
                }
                
                var body: AnyObject?
                do {
                    body = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                } catch {
                    print(error)
                }
                
                completion(statusCode: httpResponse.statusCode, responseObject: body, error: error)
            })
        }.resume()
    }
}

public class WebAPIInjectedResponse {
    public var statusCode: Int = 0
    public var responseObject: AnyObject?
    public var error: NSError?
    public var timeout: UInt64 = 0
}
