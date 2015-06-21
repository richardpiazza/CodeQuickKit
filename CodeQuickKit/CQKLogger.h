/*
 *  CQKLogger.h
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

typedef enum : NSUInteger {
    CQKLoggerLevelDebug = 0,
    CQKLoggerLevelInfo,
    CQKLoggerLevelWarn,
    CQKLoggerLevelError
} CQKLoggerLevel;

@protocol CQKLoggerAgent <NSObject>
@required
- (void)log:(CQKLoggerLevel)level message:(NSString *)message error:(NSError *)error class:(__unsafe_unretained Class)callingClass;
@end

@interface CQKLoggerConfiguration : NSObject
@property (nonatomic, assign) BOOL logToConsole;
@end

@interface CQKLogger : NSObject

+ (CQKLoggerConfiguration *)configuration;

+ (void)log:(CQKLoggerLevel)level message:(NSString *)message error:(NSError *)error class:(__unsafe_unretained Class)callingClass;

+ (void)logDebug:(NSString *)message;
+ (void)logDebugWithFormat:(NSString *)format, ...;

+ (void)logInfo:(NSString *)message;
+ (void)logInfoWithFormat:(NSString *)format, ...;

+ (void)logWarn:(NSString *)message;
+ (void)logWarnWithFormat:(NSString *)format, ...;

+ (void)logError:(NSError *)error;
+ (void)logError:(NSError *)error message:(NSString *)message;
+ (void)logError:(NSError *)error withFormat:(NSString *)format, ...;

+ (void)addAgent:(id<CQKLoggerAgent>)agent;
+ (void)removeAgent:(id<CQKLoggerAgent>)agent;

+ (NSString *)stringForLoggerLevel:(CQKLoggerLevel)level;

@end

extern NSString * const CQKLoggerLevelDebugValue;
extern NSString * const CQKLoggerLevelInfoValue;
extern NSString * const CQKLoggerLevelWarnValue;
extern NSString * const CQKLoggerLevelErrorValue;

