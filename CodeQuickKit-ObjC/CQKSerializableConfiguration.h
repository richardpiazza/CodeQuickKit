/*
 *  CQKSerializableConfiguration.h
 *
 *  Copyright (c) 2016 Richard Piazza
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

/*!
 @abstract  Casing styles for CQKSerializableNSObject properties. (Default .MatchCase)
 */
typedef enum : NSUInteger {
    CQKSerializableNSObjectKeyStyleMatchCase = 0,
    CQKSerializableNSObjectKeyStyleTitleCase,
    CQKSerializableNSObjectKeyStyleCamelCase,
    CQKSerializableNSObjectKeyStyleUpperCase,
    CQKSerializableNSObjectKeyStyleLowerCase
} CQKSerializableNSObjectKeyStyle;

/*!
 @abstract      CQKSerializableConfiguration
 @discussion    Options controlling the de/serialization and logging of the
                CQKSerializable objects.
 */
@interface CQKSerializableConfiguration : NSObject

+ (nonnull CQKSerializableConfiguration *)sharedConfiguration;

/*! @abstract   Allows for the overriding of the objects property key casing style. */
@property (nonatomic, assign) CQKSerializableNSObjectKeyStyle propertyKeyStyle;
/*! @abstract   Allows for the overriding of the objects serialized key casing style. */
@property (nonatomic, assign) CQKSerializableNSObjectKeyStyle serializedKeyStyle;
/*! @abstract   Redirects that should be applied during the de/serialization process.
                key = propertyName, value = serializedKey */
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSString *> * _Nonnull keyRedirects;

- (nullable NSString *)propertyNameForSerializedKey:(nullable NSString *)serializedKey;
- (nullable NSString *)serializedKeyForPropertyName:(nullable NSString *)propertyName;

+ (nullable NSString *)stringForPropertyName:(nullable NSString *)propertyName withKeyStyle:(CQKSerializableNSObjectKeyStyle)keyStyle;
+ (nullable NSString *)jsonStringRemovingPrettyFormatting:(nullable NSString *)json;

@end
