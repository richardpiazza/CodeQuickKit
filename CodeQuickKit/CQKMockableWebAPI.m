//
//  CQKMockableWebAPI.m
//  
//
//  Created by Richard Piazza on 12/10/15.
//
//

#import "CQKMockableWebAPI.h"
#import "CQKLogger.h"

@implementation CQKMockableWebAPIResponse
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

@interface CQKMockableWebAPI ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, CQKMockableWebAPIResponse*> *responses;
@end

@implementation CQKMockableWebAPI

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        [self setResponses:[NSMutableDictionary dictionary]];
    }
    return self;
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
    
    NSString *key = [request.URL absoluteString];
    CQKMockableWebAPIResponse *response = [self.responses objectForKey:key];
    if (key == nil || response == nil) {
        NSError *error = [CQKWebAPI invalidURL];
        if (completion != nil) {
            completion(404, nil, error);
        } else {
            NSString *message = [NSString stringWithFormat:@"Failed to execute request: %@", request];
            [CQKLogger log:CQKLoggerLevelInfo message:message error:error callingClass:self.class];
        }
        return;
    }
    
    if (completion != nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(response.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion(response.statusCode, response.responseObject, response.error);
        });
    }
}

@end
