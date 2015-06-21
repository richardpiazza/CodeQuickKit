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

@interface CQKWebAPI() <NSURLSessionTaskDelegate>
@property (nonatomic, copy) NSURLSession *session;
@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) NSDateFormatter *rfc1123DateFormatter;
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
    [self performRequestForPath:path withMethod:CQKWebAPIRequestMethodGet data:nil completion:completion];
}

- (void)putData:(NSData *)data toPath:(NSString *)path completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path withMethod:CQKWebAPIRequestMethodPut data:data completion:completion];
}

- (void)postData:(NSData *)data toPath:(NSString *)path completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path withMethod:CQKWebAPIRequestMethodPost data:data completion:completion];
}

- (void)deletePath:(NSString *)path completion:(CQKWebAPICompletion)completion
{
    [self performRequestForPath:path withMethod:CQKWebAPIRequestMethodDelete data:nil completion:completion];
}

- (void)performRequestForPath:(NSString *)path withMethod:(NSString *)method data:(NSData *)data completion:(CQKWebAPICompletion)completion
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:path];
    [self performRequestForURL:url withMethod:method data:data completion:completion];
}

- (void)performRequestForURL:(NSURL *)url withMethod:(NSString *)method data:(NSData *)data completion:(CQKWebAPICompletion)completion
{
    NSMutableURLRequest *request = [self requestForURL:url withMethod:method data:data];
    [self executeRequest:request completion:completion];
}

- (NSMutableURLRequest *)requestForPath:(NSString *)path withMethod:(NSString *)method data:(NSData *)data
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:path];
    return [self requestForURL:url withMethod:method data:data];
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

- (NSMutableURLRequest *)requestForPath:(NSString *)path withMethod:(NSString *)method imageData:(NSData *)imageData
{
    NSURL *url = [self.baseURL URLByAppendingPathComponent:path];
    return [self requestForURL:url withMethod:method imageData:imageData];
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
            [CQKLogger logError:error withFormat:@"Failed to execute request: %@", request];
        }
        return;
    }
    
    if (self.baseURL == nil) {
        NSError *error = [CQKWebAPI invalidURL];
        if (completion != nil) {
            completion(0, nil, error);
        } else {
            [CQKLogger logError:error withFormat:@"Failed to execute request: %@", request];
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
                    [CQKLogger logError:error message:@"dataTaskWithRequest Failed"];
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
                        [CQKLogger logError:serializationError message:@"CQKWebAPI Serialization Failed"];
                    }
                }
                
                if (completion != nil) {
                    completion((int)httpResponse.statusCode, body, error);
                } else {
                    [CQKLogger logError:error withFormat:@"Request complete: %d %@", (int)httpResponse.statusCode, body];
                }
                return;
            }
            
            if (responseData.length != 0 && [[httpResponse.allHeaderFields valueForKey:CQKWebAPIContentTypeHeaderKey] hasPrefix:CQKWebAPIApplicationJsonHeaderValue]) {
                NSError *serializationError;
                id body = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&serializationError];
                if (completion != nil) {
                    completion((int)httpResponse.statusCode, body, serializationError);
                } else {
                    [CQKLogger logError:serializationError withFormat:@"Request complete: %d %@", (int)httpResponse.statusCode, body];
                }
                return;
            }
            
            if (completion != nil) {
                completion((int)httpResponse.statusCode, responseData, error);
            } else {
                [CQKLogger logError:error withFormat:@"Request complete: %d %@", (int)httpResponse.statusCode, responseData];
            }
        });
    }] resume];
}

#pragma mark - NSURLSessionTaskDelegate -
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if (challenge.previousFailureCount < 1) {
        NSURLCredential *credentials = [[NSURLCredential alloc] initWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceForSession];
        if (completionHandler != nil) {
            completionHandler(NSURLSessionAuthChallengeUseCredential, credentials);
        }
        return;
    }
    
    // Authentication Failed
    [self setUsername:nil];
    [self setPassword:nil];
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
