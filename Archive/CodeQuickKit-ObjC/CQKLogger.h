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
    CQKLoggerLevelVerbose = 0,
    CQKLoggerLevelDebug,
    CQKLoggerLevelInfo,
    CQKLoggerLevelWarn,
    CQKLoggerLevelError,
    CQKLoggerLevelException
} CQKLoggerLevel;

@protocol CQKLoggerAgent <NSObject>
@required
- (void)log:(CQKLoggerLevel)level message:(NSString * _Nullable)message error:(NSError * _Nullable)error callingClass:(__unsafe_unretained Class _Nullable)callingClass;
@end

@interface CQKLoggerConfiguration : NSObject
/*! @abstract   Sets the minimum level that will automatically log to console; default is .Debug */
@property (nonatomic, assign) CQKLoggerLevel minimumConsoleLevel;
@end

/*!
 @abstract  CQKLogger
            Provides an extensible logging class. Add a logging agent
            to recieve all notifications from the CodeQuickKit
 */
@interface CQKLogger : NSObject

+ (nonnull CQKLoggerConfiguration *)configuration;

+ (void)log:(CQKLoggerLevel)level message:(nullable NSString *)message error:(nullable NSError *)error callingClass:(nullable __unsafe_unretained Class)callingClass;

+ (void)logVerbose:(nullable NSString *)message;
+ (void)logVerboseWithFormat:(nullable NSString *)format, ...;

+ (void)logDebug:(nullable NSString *)message;
+ (void)logDebugWithFormat:(nullable NSString *)format, ...;

+ (void)logInfo:(nullable NSString *)message;
+ (void)logInfoWithFormat:(nullable NSString *)format, ...;

+ (void)logWarn:(nullable NSString *)message;
+ (void)logWarnWithFormat:(nullable NSString *)format, ...;

+ (void)logError:(nullable NSError *)error;
+ (void)logError:(nullable NSError *)error message:(nullable NSString *)message;
+ (void)logError:(nullable NSError *)error withFormat:(nullable NSString *)format, ...;

+ (void)logException:(nullable NSException *)exception;
+ (void)logException:(nullable NSException *)exception message:(nullable NSString *)message;
+ (void)logException:(nullable NSException *)exception withFormat:(nullable NSString *)format, ...;

+ (void)addAgent:(nonnull id<CQKLoggerAgent>)agent;
+ (void)removeAgent:(nonnull id<CQKLoggerAgent>)agent;

+ (nonnull NSString *)stringForLoggerLevel:(CQKLoggerLevel)level;

@end

extern NSString * const _Nonnull CQKLoggerLevelVerboseValue;
extern NSString * const _Nonnull CQKLoggerLevelDebugValue;
extern NSString * const _Nonnull CQKLoggerLevelInfoValue;
extern NSString * const _Nonnull CQKLoggerLevelWarnValue;
extern NSString * const _Nonnull CQKLoggerLevelErrorValue;
extern NSString * const _Nonnull CQKLoggerLevelExceptionValue;

