/*
 *  CQKLogger.m
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

#import "CQKLogger.h"

@implementation CQKLoggerConfiguration

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        [self setLogToConsole:YES];
    }
    return self;
}

@end

@implementation CQKLogger

static NSMutableArray *agents;

+ (void)initialize
{
    if (agents == nil) {
        agents = [NSMutableArray array];
    }
}

+ (CQKLoggerConfiguration *)configuration
{
    static CQKLoggerConfiguration *_configuration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _configuration = [[CQKLoggerConfiguration alloc] init];
    });
    return _configuration;
}

+ (void)log:(CQKLoggerLevel)level message:(NSString *)message error:(NSError *)error class:(__unsafe_unretained Class)callingClass
{
    if ([[CQKLogger configuration] logToConsole]) {
        NSString *levelString = [CQKLogger stringForLoggerLevel:level];
        NSString *classString = NSStringFromClass(callingClass);
        if (error == nil) {
            NSLog(@"[%@] (Class: %@) %@", levelString, classString, message);
        } else {
            NSLog(@"[%@] (Class: %@) %@\n%@", levelString, classString, message, error);
        }
    }
    
    for (id<CQKLoggerAgent> agent in agents) {
        [agent log:level message:message error:error class:callingClass];
    }
}

+ (void)logDebug:(NSString *)message
{
    [self log:CQKLoggerLevelDebug message:message error:nil class:[self class]];
}

+ (void)logDebugWithFormat:(NSString *)format, ...
{
    NSString *message = nil;
    
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self logDebug:message];
}

+ (void)logInfo:(NSString *)message
{
    [self log:CQKLoggerLevelInfo message:message error:nil class:[self class]];
}

+ (void)logInfoWithFormat:(NSString *)format, ...
{
    NSString *message = nil;
    
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self logInfo:message];
}

+ (void)logWarn:(NSString *)message
{
    [self log:CQKLoggerLevelWarn message:message error:nil class:[self class]];
}

+ (void)logWarnWithFormat:(NSString *)format, ...
{
    NSString *message = nil;
    
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self logWarn:message];
}

+ (void)logError:(NSError *)error
{
    [self logError:error message:nil];
}

+ (void)logError:(NSError *)error message:(NSString *)message
{
    [self log:CQKLoggerLevelError message:message error:error class:[self class]];
}

+ (void)logError:(NSError *)error withFormat:(NSString *)format, ...
{
    NSString *message = nil;
    
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self logError:error message:message];
}

+ (void)logException:(NSException *)exception
{
    [self logException:exception message:nil];
}

+ (void)logException:(NSException *)exception message:(NSString *)message
{
    NSError *error = nil;
    if (exception != nil) {
        NSString *description = (exception.name != nil) ? exception.name : @"Unknown Exception";
        NSString *reason = (exception.reason != nil) ? exception.reason : @"Unknown Reason";
        NSDictionary *info = @{NSLocalizedDescriptionKey:description,
                               NSLocalizedFailureReasonErrorKey:reason};
        error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:info];
    }
    
    [self log:CQKLoggerLevelException message:message error:error class:[self class]];
}

+ (void)logException:(NSException *)exception withFormat:(NSString *)format, ...
{
    NSString *message = nil;
    
    va_list args;
    va_start(args, format);
    message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self logException:exception message:message];
}

+ (void)addAgent:(id<CQKLoggerAgent>)agent
{
    if (agent == nil) {
        return;
    }
    
    if ([agents containsObject:agent]) {
        return;
    }
    
    [agents addObject:agent];
}

+ (void)removeAgent:(id<CQKLoggerAgent>)agent
{
    if (agent == nil) {
        return;
    }
    
    if (![agents containsObject:agent]) {
        return;
    }
    
    [agents removeObject:agent];
}

+ (NSString *)stringForLoggerLevel:(CQKLoggerLevel)level
{
    switch (level) {
        case CQKLoggerLevelException: return CQKLoggerLevelExceptionValue;
        case CQKLoggerLevelError: return CQKLoggerLevelErrorValue;
        case CQKLoggerLevelWarn: return CQKLoggerLevelWarnValue;
        case CQKLoggerLevelInfo: return CQKLoggerLevelInfoValue;
        default: return CQKLoggerLevelDebugValue;
    }
}

@end

NSString * const CQKLoggerLevelDebugValue = @"Debug";
NSString * const CQKLoggerLevelInfoValue = @"Info";
NSString * const CQKLoggerLevelWarnValue = @"Warn";
NSString * const CQKLoggerLevelErrorValue = @"Error";
NSString * const CQKLoggerLevelExceptionValue = @"Exception";
