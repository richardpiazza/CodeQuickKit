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

typedef void (^CQKWebAPICompletion)(int statusCode, id _Nullable responseObject, NSError * _Nullable error);

/// A wrapper for NSURLSession for communication with JSON Web API's
/// Features:
/// - automatic deserialization of a JSON response
/// - basic auth authentication challenges
/// - mockability with injected responses
@interface CQKWebAPI : NSObject

@property (nonatomic, copy, readonly) NSURLSession * _Nonnull session;
@property (nonatomic, copy, readonly) NSURL * _Nullable baseURL;
@property (nonatomic, copy, readonly) NSString * _Nullable username;
@property (nonatomic, copy, readonly) NSString * _Nullable password;
@property (nonatomic, assign) BOOL ignoreSSL;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, CQKWebAPIInjectedResponse *> * _Nonnull injectedResponses;

- (nonnull instancetype)initWithBaseURL:(nullable NSURL *)baseURL;
- (nonnull instancetype)initWithBaseURL:(nullable NSURL *)baseURL username:(nullable NSString *)username password:(nullable NSString *)password;

- (void)getPath:(nullable NSString *)path completion:(nullable CQKWebAPICompletion)completion;
- (void)getPath:(nullable NSString *)path queryItems:(nullable NSArray<NSURLQueryItem *> *)queryItems completion:(nullable CQKWebAPICompletion)completion;
- (void)putData:(nullable NSData *)data toPath:(nullable NSString *)path completion:(nullable CQKWebAPICompletion)completion;
- (void)putData:(nullable NSData *)data toPath:(nullable NSString *)path queryItems:(nullable NSArray<NSURLQueryItem *> *)queryItems completion:(nullable CQKWebAPICompletion)completion;
- (void)postData:(nullable NSData *)data toPath:(nullable NSString *)path completion:(nullable CQKWebAPICompletion)completion;
- (void)postData:(nullable NSData *)data toPath:(nullable NSString *)path queryItems:(nullable NSArray<NSURLQueryItem *> *)queryItems completion:(nullable CQKWebAPICompletion)completion;
- (void)deletePath:(nullable NSString *)path completion:(nullable CQKWebAPICompletion)completion;
- (void)deletePath:(nullable NSString *)path queryItems:(nullable NSArray<NSURLQueryItem *> *)queryItems completion:(nullable CQKWebAPICompletion)completion;

/// Convenience method that constructs a full URL from the baseURL and provided path.
- (nonnull NSMutableURLRequest *)requestForPath:(nullable NSString *)path queryItems:(nullable NSArray<NSURLQueryItem *> *)queryItems withMethod:(nonnull NSString *)method data:(nullable NSData *)data;
/// Constructs the request, setting the method and headers as well as the body data when present.
- (nonnull NSMutableURLRequest *)requestForURL:(nullable NSURL *)url withMethod:(nonnull NSString *)method data:(nullable NSData *)data;

/// Convenience method that constructs a full URL from the baseURL and provided path.
- (nonnull NSMutableURLRequest *)requestForPath:(nullable NSString *)path queryItems:(nullable NSArray<NSURLQueryItem *> *)queryItems withMethod:(nonnull NSString *)method imageData:(nullable NSData *)imageData;
/// Transforms requestForURL:withMethod:data: request into multipart/form-data
/// The image uploaded will have the content-type 'image/png' with the filename 'image.png'
- (nonnull NSMutableURLRequest *)requestForURL:(nullable NSURL *)url withMethod:(nonnull NSString *)method imageData:(nullable NSData *)imageData;

- (void)executeRequest:(nullable NSMutableURLRequest *)request completion:(nonnull CQKWebAPICompletion)completion;

+ (nonnull NSError *)invalidURL;
+ (nonnull NSError *)invalidRequest;

@end

@interface CQKWebAPIInjectedResponse : NSObject
@property (nonatomic, assign) int statusCode;
@property (nonatomic, copy) id _Nullable responseObject;
@property (nonatomic, copy) NSError * _Nullable error;
@property (nonatomic, assign) unsigned long long timeout;
@end

#pragma mark - Standard HTTP Request Methods -
extern NSString * _Nonnull const CQKWebAPIRequestMethodGet;
extern NSString * _Nonnull const CQKWebAPIRequestMethodPut;
extern NSString * _Nonnull const CQKWebAPIRequestMethodPost;
extern NSString * _Nonnull const CQKWebAPIRequestMethodDelete;
#pragma mark - Standard HTTP Header Keys -
extern NSString * _Nonnull const CQKWebAPIAcceptHeaderKey;
extern NSString * _Nonnull const CQKWebAPIDateHeaderKey;
extern NSString * _Nonnull const CQKWebAPIContentTypeHeaderKey;
extern NSString * _Nonnull const CQKWebAPIContentMD5HeaderKey;
extern NSString * _Nonnull const CQKWebAPIContentLengthHeaderKey;
extern NSString * _Nonnull const CQKWebAPIAuthorizationHeaderKey;
#pragma mark - Standard HTTP Header Values -
extern NSString * _Nonnull const CQKWebAPIApplicationJsonHeaderValue;
