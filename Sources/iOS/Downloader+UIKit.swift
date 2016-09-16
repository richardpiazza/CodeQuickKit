//===----------------------------------------------------------------------===//
//
// Downloader+UIKit.swift
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

import UIKit

public typealias DownloaderImageCompletion = (_ statusCode: Int, _ responseImage: UIImage?, _ error: NSError?) -> Void

/// A wrapper for `NSURLSession` similar to `WebAPI` for general purpose
/// downloading of data and images.
public extension Downloader {
    public func getImageAtPath(_ path: String, cachePolicy: NSURLRequest.CachePolicy, completion: @escaping DownloaderImageCompletion) {
        guard let url = self.urlForPath(path) else {
            completion(0, nil, invalidBaseURL)
            return
        }
        
        self.getImageAtURL(url, cachePolicy: cachePolicy, completion: completion)
    }
    
    public func getImageAtURL(_ url: URL, cachePolicy: NSURLRequest.CachePolicy, completion: @escaping DownloaderImageCompletion) {
        self.getDataAtURL(url, cachePolicy: cachePolicy) { (statusCode, responseData, error) -> Void in
            var image: UIImage?
            if responseData != nil {
                image = UIImage(data: responseData!)
            }
            
            completion(statusCode, image, error)
        }
    }
}
