/*
 *  UIStoryboard+CQKStoryboards.h
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

@protocol CQKUbiquityUserDefaultsDelegate;

/*!
 @abstract      CQKUbiquityUserDefaults
 @discussion    Provides methods for interacting with NSUserDefaults key/value storage with or without iCloud Support.
                Objects saved to the user defaults are saved as an NSDictionary with additional fields for
                comparisson when syncing with the NSUbiquitiosKeyValueStore; The layout is as follows:
                {
                    CQKUbiquityUserDefaultsValueKey:(id)value
                    CQKUbiquityUserDefaultsTimestampKey:(NSDate *)timestamp
                    CQKUbiquityUserDefaultsBuildKey:(NSString *)build
                }
 */
@interface CQKUbiquityUserDefaults : NSObject

+ (CQKUbiquityUserDefaults *)ubiquityUserDefaults;

@property (nonatomic, weak) id<CQKUbiquityUserDefaultsDelegate> delegate;
@property (nonatomic, strong, readonly) NSUbiquitousKeyValueStore *keyValueStore;

@end

@protocol CQKUbiquityUserDefaultsDelegate <NSObject>
@required
- (BOOL)ubiquityUserDefaults:(CQKUbiquityUserDefaults *)ubiquityUserDefaults shouldReplaceExistingDictionary:(NSDictionary *)existingDictionary withUbiquityDictionary:(NSDictionary *)ubiquityDictionary;
@optional
- (void)ubiquityUserDefaults:(CQKUbiquityUserDefaults *)ubiquityUserDefaults didSetDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;
@end

extern NSString * const CQKUbiquityUserDefaultsValueKey;
extern NSString * const CQKUbiquityUserDefaultsTimestampKey;
extern NSString * const CQKUbiquityUserDefaultsBuildKey;
