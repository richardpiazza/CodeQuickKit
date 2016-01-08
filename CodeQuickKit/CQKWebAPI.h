/*
 *  CQKWebAPI.h
 *
 *  Copyright (c) 2015 Richard Piazza
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

#import <Foundation/Foundation.h>
@class CQKWebAPIInjectedResponse;

typedef void (^CQKWebAPICompletion)(int statusCode, id responseObject, NSError *error);

/// A wrapper for NSURLSession for communication with JSON Web API's
/// Features:
/// - automatic deserialization of a JSON response
/// - basic auth authentication challenges
/// - mockability with injected responses
@interface CQKWebAPI : NSObject

@property (nonatomic, copy, readonly) NSURLSession *session;
@property (nonatomic, copy, readonly) NSURL *baseURL;
@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, assign) BOOL ignoreSSL;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, CQKWebAPIInjectedResponse *> *injectedResponses;

- (instancetype)initWithBaseURL:(NSURL *)baseURL username:(NSString *)username password:(NSString *)password;

- (void)getPath:(NSString *)path completion:(CQKWebAPICompletion)completion;
- (void)getPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems completion:(CQKWebAPICompletion)completion;
- (void)putData:(NSData *)data toPath:(NSString *)path completion:(CQKWebAPICompletion)completion;
- (void)putData:(NSData *)data toPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems completion:(CQKWebAPICompletion)completion;
- (void)postData:(NSData *)data toPath:(NSString *)path completion:(CQKWebAPICompletion)completion;
- (void)postData:(NSData *)data toPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems completion:(CQKWebAPICompletion)completion;
- (void)deletePath:(NSString *)path completion:(CQKWebAPICompletion)completion;
- (void)deletePath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems completion:(CQKWebAPICompletion)completion;

/// Convenience method that constructs a full URL from the baseURL and provided path.
- (NSMutableURLRequest *)requestForPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems withMethod:(NSString *)method data:(NSData *)data;
/// Constructs the request, setting the method and headers as well as the body data when present.
- (NSMutableURLRequest *)requestForURL:(NSURL *)url withMethod:(NSString *)method data:(NSData *)data;

/// Convenience method that constructs a full URL from the baseURL and provided path.
- (NSMutableURLRequest *)requestForPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems withMethod:(NSString *)method imageData:(NSData *)imageData;
/// Transforms requestForURL:withMethod:data: request into multipart/form-data
/// The image uploaded will have the content-type 'image/png' with the filename 'image.png'
- (NSMutableURLRequest *)requestForURL:(NSURL *)url withMethod:(NSString *)method imageData:(NSData *)imageData;

- (void)executeRequest:(NSMutableURLRequest *)request completion:(CQKWebAPICompletion)completion;

+ (NSError *)invalidURL;
+ (NSError *)invalidRequest;

@end

@interface CQKWebAPIInjectedResponse : NSObject
@property (nonatomic, assign) int statusCode;
@property (nonatomic, copy) id responseObject;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, assign) unsigned long long timeout;
@end

#pragma mark - Standard HTTP Request Methods -
extern NSString * const CQKWebAPIRequestMethodGet;
extern NSString * const CQKWebAPIRequestMethodPut;
extern NSString * const CQKWebAPIRequestMethodPost;
extern NSString * const CQKWebAPIRequestMethodDelete;
#pragma mark - Standard HTTP Header Keys -
extern NSString * const CQKWebAPIAcceptHeaderKey;
extern NSString * const CQKWebAPIDateHeaderKey;
extern NSString * const CQKWebAPIContentTypeHeaderKey;
extern NSString * const CQKWebAPIContentMD5HeaderKey;
extern NSString * const CQKWebAPIContentLengthHeaderKey;
extern NSString * const CQKWebAPIAuthorizationHeaderKey;
#pragma mark - Standard HTTP Header Values -
extern NSString * const CQKWebAPIApplicationJsonHeaderValue;
