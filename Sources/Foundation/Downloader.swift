//===----------------------------------------------------------------------===//
//
// Downloader.swift
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

public typealias DownloaderDataCompletion = (statusCode: Int, responseData: NSData?, error: NSError?) -> Void

/// A wrapper for `NSURLSession` similar to `WebAPI` for general purpose
/// downloading of data and images.
public class Downloader {
    private static let twentyFiveMB: Int = (1024 * 1024 * 25)
    private static let twoHundredMB: Int = (1024 * 1024 * 200)
    
    private lazy var session: NSURLSession = {
        [unowned self] in
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.URLCache = self.cache
        configuration.requestCachePolicy = .ReturnCacheDataElseLoad
        return NSURLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()
    private var cache: NSURLCache = NSURLCache(memoryCapacity: Downloader.twentyFiveMB, diskCapacity: Downloader.twoHundredMB, diskPath: "Downloader")
    public var baseURL: NSURL?
    public var timeout: NSTimeInterval = 20
    
    internal lazy var invalidBaseURL: NSError = {
        let userInfo: [String : AnyObject] = [NSLocalizedDescriptionKey:"Invalid Base URL", NSLocalizedFailureReasonErrorKey:"You can not use a `path` method without specifiying a baseURL."]
        return NSError(domain: "Downloader", code: 0, userInfo: userInfo)
    }()
    
    public init() {
    }
    
    public convenience init(baseURL: NSURL) {
        self.init()
        self.baseURL = baseURL
    }
    
    internal func urlForPath(path: String) -> NSURL? {
        guard let baseURL = self.baseURL else {
            return nil
        }
        
        return baseURL.URLByAppendingPathComponent(path)
    }
    
    public func getDataAtPath(path: String, cachePolicy: NSURLRequestCachePolicy, completion: DownloaderDataCompletion) {
        guard let url = self.urlForPath(path) else {
            completion(statusCode: 0, responseData: nil, error: invalidBaseURL)
            return
        }
        
        self.getDataAtURL(url, cachePolicy: cachePolicy, completion: completion)
    }
    
    public func getDataAtURL(url: NSURL, cachePolicy: NSURLRequestCachePolicy, completion: DownloaderDataCompletion) {
        let request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.HTTPMethod = "GET"
        
        session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard error == nil else {
                    completion(statusCode: 0, responseData: data, error: error)
                    return
                }
                
                let httpResponse = response as! NSHTTPURLResponse
                completion(statusCode: httpResponse.statusCode, responseData: data, error: error)
            })
        }.resume()
    }
}
