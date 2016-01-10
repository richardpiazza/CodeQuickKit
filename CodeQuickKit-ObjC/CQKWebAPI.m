/*
 *  CQKWebAPI.m
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

#import "CQKWebAPI.h"
#import "CQKLogger.h"
#import "NSData+CQKCrypto.h"

@implementation CQKWebAPIInjectedResponse

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        self.statusCode = 0;
        self.timeout = 0;
    }
    return self;
}

@end

@interface CQKWebAPI() <NSURLSessionTaskDelegate>
@property (nonatomic, copy) NSURLSession *session;
@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) NSDateFormatter *rfc1123DateFormatter;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CQKWebAPIInjectedResponse *> *injectedResponses;
- (void)performRequestForPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems withMethod:(NSString *)method data:(NSData *)data completion:(CQKWebAPICompletion)completion;
- (void)performRequestForURL:(NSURL *)url withMethod:(NSString *)method data:(NSData *)data completion:(CQKWebAPICompletion)completion;
@end

@implementation CQKWebAPI

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        [self setRfc1123DateFormatter:[[NSDateFormatter alloc] init]];
        [self.rfc1123DateFormatter  setDateFormat:@"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"];
        [self.rfc1123DateFormatter  setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [self.rfc1123DateFormatter  setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [self setInjectedResponses:[NSMutableDictionary dictionary]];
        [self setSession:[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil]];
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL username:(NSString *)username password:(NSString *)password
{
    self = [self init];
    if (self != nil) {
        [self setBaseURL:baseURL];
        [self setUsername:username];
        [self setPassword:password];
    }
    return self;
}

- (void)getPath:(NSString *)path completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path queryItems:nil withMethod:CQKWebAPIRequestMethodGet data:nil completion:completion];
}

- (void)getPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path queryItems:queryItems withMethod:CQKWebAPIRequestMethodGet data:nil completion:completion];
}

- (void)putData:(NSData *)data toPath:(NSString *)path completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path queryItems:nil withMethod:CQKWebAPIRequestMethodPut data:data completion:completion];
}

- (void)putData:(NSData *)data toPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path queryItems:queryItems withMethod:CQKWebAPIRequestMethodPut data:data completion:completion];
}

- (void)postData:(NSData *)data toPath:(NSString *)path completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path queryItems:nil withMethod:CQKWebAPIRequestMethodPost data:data completion:completion];
}

- (void)postData:(NSData *)data toPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path queryItems:queryItems withMethod:CQKWebAPIRequestMethodPost data:data completion:completion];
}

- (void)deletePath:(NSString *)path completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path queryItems:nil withMethod:CQKWebAPIRequestMethodDelete data:nil completion:completion];
}

- (void)deletePath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path queryItems:queryItems withMethod:CQKWebAPIRequestMethodDelete data:nil completion:completion];
}

- (void)performRequestForPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems withMethod:(NSString *)method data:(NSData *)data completion:(CQKWebAPICompletion)completion
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:path];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:url.absoluteString];
    if (queryItems != nil) {
        [urlComponents setQueryItems:queryItems];
    }
    [self performRequestForURL:urlComponents.URL withMethod:method data:data completion:completion];
}

- (void)performRequestForURL:(NSURL *)url withMethod:(NSString *)method data:(NSData *)data completion:(CQKWebAPICompletion)completion
{
    NSMutableURLRequest *request = [self requestForURL:url withMethod:method data:data];
    [self executeRequest:request completion:completion];
}

- (NSMutableURLRequest *)requestForPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems withMethod:(NSString *)method data:(NSData *)data
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:path];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:url.absoluteString];
    if (queryItems != nil) {
        [urlComponents setQueryItems:queryItems];
    }
    return [self requestForURL:urlComponents.URL withMethod:method data:data];
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)url withMethod:(NSString *)method data:(NSData *)data
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setValue:[self.rfc1123DateFormatter stringFromDate:[NSDate date]] forHTTPHeaderField:CQKWebAPIDateHeaderKey];
    [request setValue:CQKWebAPIApplicationJsonHeaderValue forHTTPHeaderField:CQKWebAPIAcceptHeaderKey];
    
    if (data != nil && [[data class] isSubclassOfClass:[NSData class]]) {
        [request setHTTPBody:data];
        [request setValue:CQKWebAPIApplicationJsonHeaderValue forHTTPHeaderField:CQKWebAPIContentTypeHeaderKey];
        [request setValue:[[data md5Hash] base64EncodedStringWithOptions:0] forHTTPHeaderField:CQKWebAPIContentMD5HeaderKey];
    }
    
    return request;
}

- (NSMutableURLRequest *)requestForPath:(NSString *)path queryItems:(NSArray<NSURLQueryItem *> *)queryItems withMethod:(NSString *)method imageData:(NSData *)imageData
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:path];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:url.absoluteString];
    if (queryItems != nil) {
        [urlComponents setQueryItems:queryItems];
    }
    return [self requestForURL:urlComponents.URL withMethod:method imageData:imageData];
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)url withMethod:(NSString *)method imageData:(NSData *)imageData
{
    NSMutableURLRequest *request = [self requestForURL:url withMethod:method data:nil];
    
    NSMutableString *boundary = [NSMutableString stringWithString:[[NSUUID UUID] UUIDString]];
    [boundary replaceOccurrencesOfString:@"-" withString:@"" options:0 range:NSMakeRange(0, boundary.length)];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:CQKWebAPIContentTypeHeaderKey];
    
    NSMutableData *requestData = [NSMutableData data];
    
    [requestData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [requestData appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [requestData appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [requestData appendData:imageData];
    [requestData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [requestData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:[NSString stringWithFormat:@"%zu", (unsigned long)requestData.length] forHTTPHeaderField:CQKWebAPIContentLengthHeaderKey];
    [request setHTTPBody:requestData];
    
    return request;
}

- (void)executeRequest:(NSMutableURLRequest *)request completion:(CQKWebAPICompletion)completion
{
    if (request == nil) {
        NSError *error = [CQKWebAPI invalidRequest];
        if (completion != nil) {
            completion(0, nil, error);
        } else {
            NSString *message = [NSString stringWithFormat:@"Failed to execute request: %@", request];
            [CQKLogger log:CQKLoggerLevelInfo message:message error:error callingClass:self.class];
        }
        return;
    }
    
    if (self.baseURL == nil) {
        NSError *error = [CQKWebAPI invalidURL];
        if (completion != nil) {
            completion(0, nil, error);
        } else {
            NSString *message = [NSString stringWithFormat:@"Failed to execute request: %@", request];
            [CQKLogger log:CQKLoggerLevelInfo message:message error:error callingClass:self.class];
        }
        return;
    }
    
    CQKWebAPIInjectedResponse *injectedResponse = [self.injectedResponses objectForKey:[request.URL absoluteString]];
    if (injectedResponse != nil) {
        if (completion != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(injectedResponse.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion(injectedResponse.statusCode, injectedResponse.responseObject, injectedResponse.error);
            });
        } else {
            [CQKLogger log:CQKLoggerLevelWarn message:@"Injected response found but completion is nil" error:nil callingClass:self.class];
        }
        return;
    }
    
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                if (completion != nil) {
                    // An error code of -999 represents a canceled authentication challenge
                    if (error.code == -999) {
                        completion(401, nil, error);
                    } else {
                        completion(0, nil, error);
                    }
                } else {
                    [CQKLogger log:CQKLoggerLevelError message:@"dataTaskWithRequest Failed" error:error callingClass:self.class];
                }
                return;
            }
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (httpResponse.statusCode >= 400) {
                id body = nil;
                if (responseData.length != 0 && [[httpResponse.allHeaderFields valueForKey:CQKWebAPIContentTypeHeaderKey] hasPrefix:CQKWebAPIApplicationJsonHeaderValue]) {
                    NSError *serializationError;
                    body = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&serializationError];
                    if (serializationError != nil) {
                        [CQKLogger log:CQKLoggerLevelError message:@"Serialization Failed" error:serializationError callingClass:self.class];
                    }
                }
                
                if (completion != nil) {
                    completion((int)httpResponse.statusCode, body, error);
                } else {
                    NSString *message = [NSString stringWithFormat:@"Request complete: %d %@", (int)httpResponse.statusCode, body];
                    [CQKLogger log:CQKLoggerLevelInfo message:message error:nil callingClass:self.class];
                }
                return;
            }
            
            if (responseData.length != 0 && [[httpResponse.allHeaderFields valueForKey:CQKWebAPIContentTypeHeaderKey] hasPrefix:CQKWebAPIApplicationJsonHeaderValue]) {
                NSError *serializationError;
                id body = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&serializationError];
                if (completion != nil) {
                    completion((int)httpResponse.statusCode, body, serializationError);
                } else {
                    NSString *message = [NSString stringWithFormat:@"Request complete: %d %@", (int)httpResponse.statusCode, body];
                    [CQKLogger log:CQKLoggerLevelInfo message:message error:nil callingClass:self.class];
                }
                return;
            }
            
            if (completion != nil) {
                completion((int)httpResponse.statusCode, responseData, error);
            } else {
                NSString *message = [NSString stringWithFormat:@"Request complete: %d %@", (int)httpResponse.statusCode, responseData];
                [CQKLogger log:CQKLoggerLevelInfo message:message error:nil callingClass:self.class];
            }
        });
    }] resume];
}

#pragma mark - NSURLSessionTaskDelegate -
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if (challenge.previousFailureCount < 1) {
        NSURLCredential *credentials;
        
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust && self.ignoreSSL) {
            credentials = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        } else {
            credentials = [[NSURLCredential alloc] initWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceForSession];
        }
        
        NSString *message = [NSString stringWithFormat:@"Providing Credentials (%@): %@", [task.originalRequest URL], credentials];
        [CQKLogger log:CQKLoggerLevelVerbose message:message error:challenge.error callingClass:self.class];
        
        if (completionHandler != nil) {
            completionHandler(NSURLSessionAuthChallengeUseCredential, credentials);
        }
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"Canceled Authentication Challenge: %@", challenge.failureResponse];
    [CQKLogger log:CQKLoggerLevelVerbose message:message error:challenge.error callingClass:self.class];
    
    if (completionHandler != nil) {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

+ (NSError *)invalidURL
{
    static NSError *_error;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = @{NSLocalizedDescriptionKey:@"Invalid Base URL",
                               NSLocalizedFailureReasonErrorKey:@"Base URL is nil or invalid",
                               NSLocalizedRecoverySuggestionErrorKey:@"Set the base URL and try the request again."};
        _error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:info];
    });
    return _error;
}

+ (NSError *)invalidRequest
{
    static NSError *_error;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = @{NSLocalizedDescriptionKey:@"Invalid URL Request",
                               NSLocalizedFailureReasonErrorKey:@"NSURLRequest is nil or invalid",
                               NSLocalizedRecoverySuggestionErrorKey:@"Try the request again with a valid NSURLRequest."};
        _error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:info];
    });
    return _error;
}

@end

#pragma mark - Standard HTTP Request Methods -
NSString * const CQKWebAPIRequestMethodGet = @"GET";
NSString * const CQKWebAPIRequestMethodPut = @"PUT";
NSString * const CQKWebAPIRequestMethodPost = @"POST";
NSString * const CQKWebAPIRequestMethodDelete = @"DELETE";
#pragma mark - Standard HTTP Header Keys -
NSString * const CQKWebAPIAcceptHeaderKey = @"Accept";
NSString * const CQKWebAPIDateHeaderKey = @"Date";
NSString * const CQKWebAPIContentTypeHeaderKey = @"Content-Type";
NSString * const CQKWebAPIContentMD5HeaderKey = @"Content-MD5";
NSString * const CQKWebAPIContentLengthHeaderKey = @"Content-Length";
NSString * const CQKWebAPIAuthorizationHeaderKey = @"Authorization";
#pragma mark - Standard HTTP Header Values -
NSString * const CQKWebAPIApplicationJsonHeaderValue = @"application/json";
