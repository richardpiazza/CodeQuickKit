/*
 *  CQKSerializableConfiguration.m
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

#import "CQKSerializableConfiguration.h"
#import "NSDateFormatter+CQKDateFormatter.h"
#import "NSObject+CQKRuntime.h"

@interface CQKSerializableConfiguration ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> * _Nonnull keyRedirects;
@end

@implementation CQKSerializableConfiguration

+ (CQKSerializableConfiguration *)sharedConfiguration
{
    static CQKSerializableConfiguration *_sharedConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [[CQKSerializableConfiguration alloc] init];
    });
    return _sharedConfiguration;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        [self setPropertyKeyStyle:CQKSerializableNSObjectKeyStyleMatchCase];
        [self setSerializedKeyStyle:CQKSerializableNSObjectKeyStyleMatchCase];
        [self setKeyRedirects:[[NSMutableDictionary alloc] init]];
        [self setDateFormatter:[NSDateFormatter rfc1123DateFormatter]];
    }
    return self;
}

+ (NSString *)stringForString:(NSString *)string withKeyStyle:(CQKSerializableNSObjectKeyStyle)keyStyle
{
    if (string == nil || [string isEqualToString:@""]) {
        return nil;
    }
    
    if (string.length == 1) {
        return string;
    }
    
    switch (keyStyle) {
        case CQKSerializableNSObjectKeyStyleMatchCase: {
            return string;
        }
        case CQKSerializableNSObjectKeyStyleCamelCase: {
            return [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[string substringToIndex:1] lowercaseString]];
        }
        case CQKSerializableNSObjectKeyStyleTitleCase: {
            return [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[string substringToIndex:1] uppercaseString]];
        }
        case CQKSerializableNSObjectKeyStyleUpperCase: {
            return string.uppercaseString;
        }
        case CQKSerializableNSObjectKeyStyleLowerCase: {
            return string.lowercaseString;
        }
        default: {
            return string;
        }
    }
}

+ (NSString *)jsonStringRemovingPrettyFormatting:(NSString *)json
{
    if (json == nil) {
        return nil;
    }
    
    NSMutableString *jsonString = [NSMutableString stringWithString:json];
    [jsonString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, jsonString.length)];
    [jsonString replaceOccurrencesOfString:@" : " withString:@":" options:NSCaseInsensitiveSearch range:NSMakeRange(0, jsonString.length)];
    [jsonString replaceOccurrencesOfString:@"  " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, jsonString.length)];
    [jsonString replaceOccurrencesOfString:@"\\/" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, jsonString.length)];
    return jsonString;
}

// MARK: - CQKSerializableCustomizable
- (NSString *)propertyNameForSerializedKey:(NSString *)serializedKey
{
    if (serializedKey == nil) {
        return nil;
    }
    
    __block NSString *propertyName;
    [self.keyRedirects enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:serializedKey]) {
            propertyName = key;
            *stop = YES;
        }
    }];
    
    if (propertyName != nil) {
        return propertyName;
    }
    
    return [CQKSerializableConfiguration stringForString:serializedKey withKeyStyle:self.propertyKeyStyle];
}

- (NSString *)serializedKeyForPropertyName:(NSString *)propertyName
{
    if (propertyName == nil) {
        return nil;
    }
    
    __block NSString *serializedKey;
    [self.keyRedirects enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:propertyName]) {
            serializedKey = obj;
            *stop = YES;
        }
    }];
    
    if (serializedKey != nil) {
        return serializedKey;
    }
    
    return [CQKSerializableConfiguration stringForString:propertyName withKeyStyle:self.serializedKeyStyle];
}

- (NSObject *)initializedObjectForPropertyName:(NSString *)propertyName ofClass:(Class)ofClass withData:(__kindof NSObject *)data
{
    if (ofClass == nil || propertyName == nil || data == nil) {
        return nil;
    }
    
    Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:ofClass];
    
    if ([propertyClass isSubclassOfClass:[NSUUID class]]) {
        return [[NSUUID alloc] initWithUUIDString:(NSString *)data];
    } else if ([propertyClass isSubclassOfClass:[NSDate class]]) {
        return [self.dateFormatter dateFromString:(NSString *)data];
    } else if ([propertyClass isSubclassOfClass:[NSURL class]]) {
        return [NSURL URLWithString:(NSString *)data];
    }
    
    return data;
}

- (NSObject *)serializedObjectForPropertyName:(NSString *)propertyName withData:(__kindof NSObject *)data
{
    if (propertyName == nil || data == nil) {
        return nil;
    }
    
    if ([[data class] isSubclassOfClass:[NSUUID class]]) {
        return [(NSUUID *)data UUIDString];
    } else if ([[data class] isSubclassOfClass:[NSDate class]]) {
        return [self.dateFormatter stringFromDate:(NSDate *)data];
    } else if ([[data class] isSubclassOfClass:[NSURL class]]) {
        return [(NSURL *)data absoluteString];
    }
    
    return data;
}

@end
