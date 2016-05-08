//===----------------------------------------------------------------------===//
//
// WebAPI.swift
//
// Copyright (c) 2016 Richard Piazza
// https://github.com/richardpiazza/CodeQuickKit
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

public enum WebAPIRequestMethod: String {
    case Get = "GET"
    case Put = "PUT"
    case Post = "POST"
    case Delete = "DELETE"
}

public struct WebAPIHeaderKey {
    public static let Accept = "Accept"
    public static let Date = "Date"
    public static let ContentType = "Content-Type"
    public static let ContentMD5 = "Content-MD5"
    public static let ContentLength = "Content-Length"
    public static let Authorization = "Authorization"
}

public struct WebAPIHeaderValue {
    public static let ApplicationJson = "application/json"
    public static let ImagePNG = "image/png"
}

public struct WebAPIInjectedResponse {
    public var statusCode: Int = 0
    public var responseObject: AnyObject?
    public var error: NSError?
    public var timeout: UInt64 = 0
}

public enum WebAPIError: ErrorType {
    case InvalidURL
    case InvalidRequest
    
    public var description: String {
        switch self {
        case .InvalidURL: return "Invalid Base URL"
        case .InvalidRequest: return "Invalid URL Request"
        }
    }
    
    public var failureReason: String {
        switch self {
        case .InvalidURL: return "Base URL is nil or invalid"
        case .InvalidRequest: return "NSURLRequest is nil or invalid"
        }
    }
    
    public var recoverySuggestion: String {
        switch self {
        case .InvalidURL: return "Set the base URL and try the request again."
        case .InvalidRequest: return "Try the request again with a valid NSURLRequest."
        }
    }
    
    public var code: Int {
        switch self {
        case .InvalidURL: return 0
        case .InvalidRequest: return 1
        }
    }
    
    public var error: NSError {
        return NSError(domain: String(WebAPI), code: code, userInfo: [NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: failureReason, NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion])
    }
}

/// # WebAPI
/// A wrapper for NSURLSession for communication with JSON REST API's
/// ### Features
/// - automatic deserialization of a JSON response
/// - mockability with injected responses
public class WebAPI {
    
    public var baseURL: NSURL?
    public var injectedResponses: [String : WebAPIInjectedResponse] = [String : WebAPIInjectedResponse]()
    public var sessionDelegate: NSURLSessionDelegate?
    public lazy var session: NSURLSession = {
        [unowned self] in
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: configuration, delegate: self.sessionDelegate, delegateQueue: nil)
    }()
    
    public init(baseURL: NSURL?, sessionDelegate: NSURLSessionDelegate?) {
        self.baseURL = baseURL
        self.sessionDelegate = sessionDelegate
    }
    
    // MARK: - Convenience Methods
    
    public final func get(path: String, queryItems: [NSURLQueryItem]? = nil, completion: WebAPICompletion) {
        execute(path, queryItems: queryItems, method: .Get, data: nil, completion: completion)
    }
    
    public final func put(data: NSData?, path: String, queryItems: [NSURLQueryItem]? = nil, completion: WebAPICompletion) {
        execute(path, queryItems: queryItems, method: .Put, data: data, completion: completion)
    }
    
    public final func post(data: NSData?, path: String, queryItems: [NSURLQueryItem]? = nil, completion: WebAPICompletion) {
        execute(path, queryItems: queryItems, method: .Post, data: data, completion: completion)
    }
    
    public final func delete(path: String, queryItems: [NSURLQueryItem]? = nil, completion: WebAPICompletion) {
        execute(path, queryItems: queryItems, method: .Delete, data: nil, completion: completion)
    }
    
    // MARK: - Request Setup
    
    /// Constructs the request, setting the method, body data, and headers based on parameters
    /// Subclasses can override this method to customize the request as needed.
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
        request.HTTPMethod = method.rawValue
        request.HTTPBody = data
        request.setValue(NSDateFormatter.rfc1123DateFormatter().stringFromDate(NSDate()), forHTTPHeaderField: WebAPIHeaderKey.Date)
        request.setValue(WebAPIHeaderValue.ApplicationJson, forHTTPHeaderField: WebAPIHeaderKey.Accept)
        request.setValue(WebAPIHeaderValue.ApplicationJson, forHTTPHeaderField: WebAPIHeaderKey.ContentType)
        
        return request
    }
    
    // MARK: - Execution
    
    /// Executes the request returned from `requestFor(path:queyItems:method:data:)`
    public final func execute(path: String, queryItems: [NSURLQueryItem]?, method: WebAPIRequestMethod, data: NSData?, completion: WebAPICompletion) {
        if let request = self.requestFor(path, queryItems: queryItems, method: method, data: data) {
            execute(request, completion: completion)
        } else {
            completion(statusCode: 0, responseObject: nil, error: WebAPIError.InvalidRequest.error)
        }
    }
    
    /// Transforms the request into a `multipart/form-data` request.
    /// The request `content-type` will be set to `image/png` and the associated filename will be `image.png`
    public final func execute(path: String, queryItems: [NSURLQueryItem]?, method: WebAPIRequestMethod, pngImageData: NSData, completion: WebAPICompletion) {
        Logger.verbose("\(#function)", callingClass: self.dynamicType)
        if let request = requestFor(path, queryItems: queryItems, method: method, data: nil) {
            let boundary = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "")
            let contentType = "multipart/form-data; boundary=\(boundary)"
            request.setValue(contentType, forHTTPHeaderField: WebAPIHeaderKey.ContentType)
            
            let data = NSMutableData()
            
            if let d = "--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding) {
                data.appendData(d)
            }
            if let d = "Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding) {
                data.appendData(d)
            }
            if let d = "Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding) {
                data.appendData(d)
            }
            data.appendData(pngImageData)
            if let d = "\r\n".dataUsingEncoding(NSUTF8StringEncoding) {
                data.appendData(d)
            }
            if let d = "--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding) {
                data.appendData(d)
            }
            
            let contentLength = String(format: "%zu", data.length)
            request.setValue(contentLength, forHTTPHeaderField: WebAPIHeaderKey.ContentLength)
            
            request.HTTPBody = data
            
            execute(request, completion: completion)
        } else {
            completion(statusCode: 0, responseObject: nil, error: WebAPIError.InvalidRequest.error)
        }
    }
    
    private func execute(request: NSMutableURLRequest, completion: WebAPICompletion) {
        Logger.verbose("\(#function)", callingClass: self.dynamicType)
        guard let url = request.URL else {
            completion(statusCode: 0, responseObject: nil, error: WebAPIError.InvalidURL.error)
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
                
                if let contentType = httpResponse.allHeaderFields[WebAPIHeaderKey.ContentType] {
                    guard contentType.hasPrefix(WebAPIHeaderValue.ApplicationJson) else {
                        completion(statusCode: httpResponse.statusCode, responseObject: nil, error: error)
                        return
                    }
                }
                
                var body: AnyObject?
                var e: NSError? = error
                do {
                    body = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                } catch {
                    if e == nil {
                        e = (error as NSError)
                    } else {
                        print(error)
                    }
                }
                
                completion(statusCode: httpResponse.statusCode, responseObject: body, error: e)
            })
        }.resume()
    }
}
