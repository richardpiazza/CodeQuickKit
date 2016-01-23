/*
 *  CQKSerializableNSObject.m
 *
 *  Copyright (c) 2014 Richard Piazza
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

#import "CQKSerializableNSObject.h"
#import "NSObject+CQKRuntime.h"
#import "NSDateFormatter+CQKDateFormatter.h"
#import "CQKSerializableConfiguration.h"
#import "CQKLogger.h"

@interface CQKSerializableNSObject ()
- (BOOL)respondsToSetterForPropertyName:(NSString *)propertyName;
- (void)setValueForPropertyName:(NSString *)propertyName withDictionary:(NSDictionary *)dictionary;
- (void)setValueForPropertyName:(NSString *)propertyName withArray:(NSArray *)array;
- (void)setValueForPropertyName:(NSString *)propertyName withObject:(id)object;
- (NSArray *)serializedArrayForPropertyName:(NSString *)propertyName withArray:(NSArray *)array;
@end

@implementation CQKSerializableNSObject

#pragma mark - NSCoding -
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self != nil) {
        
        NSArray *propertyNames = [NSObject propertyNamesForClass:self.class];
        
        for (NSString *propertyName in propertyNames) {
            if (![self respondsToSetterForPropertyName:propertyName]) {
                continue;
            }
            
            if (![decoder containsValueForKey:propertyName]) {
                continue;
            }
            
            [self setValue:[decoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    NSArray *propertyNames = [NSObject propertyNamesForClass:self.class];
    
    for (NSString *propertyName in propertyNames) {
        if (![self respondsToSelector:NSSelectorFromString(propertyName)]) {
            continue;
        }
        
        Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:self.class];
        if (![propertyClass isSubclassOfClass:[NSObject class]]) {
            continue;
        }
        
        [encoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
}

#pragma mark - NSCopying -
- (id)copyWithZone:(NSZone *)zone
{
    return [[self.class alloc] initWithDictionary:self.dictionary];
}

#pragma mark - CQKSerializable -
- (nonnull instancetype)initWithDictionary:(nullable NSDictionary *)dictionary
{
    self = [self init];
    if (self != nil) {
        [self updateWithDictionary:dictionary];
    }
    return self;
}

- (void)updateWithDictionary:(nullable NSDictionary *)dictionary
{
    if (dictionary == nil || ![[dictionary class] isSubclassOfClass:[NSDictionary class]]) {
        [CQKLogger log:CQKLoggerLevelWarn message:@"Could not updateWithDictinary:, dictionary is nil." error:nil callingClass:self.class];
        return;
    }
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *propertyName = [self propertyNameForSerializedKey:key];
        if (propertyName == nil) {
            return;
        }
        
        if (![self respondsToSetterForPropertyName:propertyName]) {
            NSString *message = [NSString stringWithFormat:@"%s[%@] Responds to setter = NO", __PRETTY_FUNCTION__, propertyName];
            [CQKLogger log:CQKLoggerLevelVerbose message:message error:nil callingClass:[self class]];
            return;
        }
        
        @try {
            if ([[obj class] isSubclassOfClass:[NSDictionary class]]) {
                [self setValueForPropertyName:propertyName withDictionary:obj];
            } else if ([[obj class] isSubclassOfClass:[NSArray class]]) {
                [self setValueForPropertyName:propertyName withArray:obj];
            } else if (![[obj class] isSubclassOfClass:[NSNull class]]) {
                [self setValueForPropertyName:propertyName withObject:obj];
            }
        }
        @catch (NSException *exception) {
            NSString *message = [NSString stringWithFormat:@"Failed to set value '%@' for key '%@': %@", obj, key, exception.reason];
            [CQKLogger log:CQKLoggerLevelException message:message error:nil callingClass:[self class]];
        }
        @finally {
            
        }
    }];
}

- (nonnull NSDictionary *)dictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSArray *properties = [NSObject propertyNamesForClass:self.class];
    for (NSString *propertyName in properties) {
        if (![self respondsToSelector:NSSelectorFromString(propertyName)]) {
            NSString *message = [NSString stringWithFormat:@"%s[%@] Responds to selector = NO", __PRETTY_FUNCTION__, propertyName];
            [CQKLogger log:CQKLoggerLevelVerbose message:message error:nil callingClass:[self class]];
            continue;
        }
        
        id valueObject = [self valueForKey:propertyName];
        if (valueObject == nil) {
            NSString *message = [NSString stringWithFormat:@"%s[%@] value = nil", __PRETTY_FUNCTION__, propertyName];
            [CQKLogger log:CQKLoggerLevelVerbose message:message error:nil callingClass:[self class]];
            continue;
        }
        
        Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:self.class];
        NSString *serializedKey = [self serializedKeyForPropertyName:propertyName];
        
        @try {
            if ([propertyClass isSubclassOfClass:[CQKSerializableNSObject class]]) {
                [dictionary setObject:[(CQKSerializableNSObject *)valueObject dictionary] forKey:serializedKey];
            } else if ([propertyClass isSubclassOfClass:[NSArray class]]) {
                [dictionary setObject:[self serializedArrayForPropertyName:propertyName withArray:valueObject] forKey:serializedKey];
            } else {
                id serializedObject = [self serializedObjectForPropertyName:propertyName withData:valueObject];
                if (serializedObject != nil) {
                    [dictionary setObject:serializedObject forKey:serializedKey];
                }
            }
        }
        @catch (NSException *exception) {
            NSString *message = [NSString stringWithFormat:@"Failed to set value '%@' for key '%@': %@", valueObject, serializedKey, exception.reason];
            [CQKLogger log:CQKLoggerLevelException message:message error:nil callingClass:[self class]];
        }
        @finally {
            
        }
    }
    
    return dictionary;
}

- (nonnull instancetype)initWithData:(nullable NSData *)data;
{
    self = [self init];
    if (self != nil) {
        [self updateWithData:data];
    }
    return self;
}

- (void)updateWithData:(nullable NSData *)data
{
    if (data == nil) {
        return;
    }
    
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (dictionary == nil || error != nil) {
        NSString *message = [NSString stringWithFormat:@"Failed to update with data '%@'", data];
        [CQKLogger log:CQKLoggerLevelError message:message error:error callingClass:[self class]];
        return;
    }
    
    [self updateWithDictionary:dictionary];
}

- (nullable NSData *)data
{
    NSDictionary *dictionary = self.dictionary;
    
    NSError *error = nil;
    NSData *data = nil;
    
    @try {
        data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
        if (data == nil || error != nil) {
            NSString *message = [NSString stringWithFormat:@"Failed with dictionary '%@'", dictionary];
            [CQKLogger log:CQKLoggerLevelError message:message error:error callingClass:[self class]];
        }
    }
    @catch (NSException *exception) {
        NSString *message = [NSString stringWithFormat:@"Failed to serialize dictionary %@", dictionary];
        [CQKLogger log:CQKLoggerLevelException message:message error:nil callingClass:[self class]];
    }
    @finally {
        return data;
    }
}

- (nonnull instancetype)initWithJSON:(nullable NSString *)json
{
    self = [self init];
    if (self != nil) {
        [self updateWithJSON:json];
    }
    return self;
}

- (void)updateWithJSON:(nullable NSString *)json
{
    if (json == nil || [json isEqualToString:@""]) {
        [CQKLogger log:CQKLoggerLevelWarn message:@"Could not updateWithJson:, json is nil." error:nil callingClass:self.class];
        return;
    }
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        [CQKLogger log:CQKLoggerLevelWarn message:@"Could not updateWithJson:, encode json failed." error:nil callingClass:self.class];
        return;
    }
    
    [self updateWithData:data];
}

- (nullable NSString *)json
{
    NSData *data = self.data;
    if (data == nil) {
        [CQKLogger log:CQKLoggerLevelWarn message:@"Could not return NSString *json, self.data is nil." error:nil callingClass:self.class];
        return nil;
    }
    
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *jsonFormatted = [CQKSerializableConfiguration jsonStringRemovingPrettyFormatting:json];
    return jsonFormatted;
}

#pragma mark -
- (nullable NSString *)propertyNameForSerializedKey:(nullable NSString *)serializedKey
{
    return [[CQKSerializableConfiguration sharedConfiguration] propertyNameForSerializedKey:serializedKey];
}

- (nullable NSString *)serializedKeyForPropertyName:(nullable NSString *)propertyName
{
    return [[CQKSerializableConfiguration sharedConfiguration] serializedKeyForPropertyName:propertyName];
}

- (nullable id <NSObject>)initializedObjectForPropertyName:(nullable NSString *)propertyName withData:(nullable id)data
{
    Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:self.class];
    
    if ([propertyClass isSubclassOfClass:[NSUUID class]]) {
        return [[NSUUID alloc] initWithUUIDString:(NSString *)data];
    } else if ([propertyClass isSubclassOfClass:[NSDate class]]) {
        return [[NSDateFormatter rfc1123DateFormatter] dateFromString:(NSString *)data];
    } else if ([propertyClass isSubclassOfClass:[NSURL class]]) {
        return [NSURL URLWithString:(NSString *)data];
    }
    
    return data;
}

- (nullable id <NSObject>)serializedObjectForPropertyName:(nullable NSString *)propertyName withData:(nullable id)data
{
    if ([[data class] isSubclassOfClass:[NSUUID class]]) {
        return [(NSUUID *)data UUIDString];
    } else if ([[data class] isSubclassOfClass:[NSDate class]]) {
        return [[NSDateFormatter rfc1123DateFormatter] stringFromDate:(NSDate *)data];
    } else if ([[data class] isSubclassOfClass:[NSURL class]]) {
        return [(NSURL *)data absoluteString];
    }
    
    return data;
}

- (BOOL)respondsToSetterForPropertyName:(NSString *)propertyName
{
    if (propertyName == nil || [propertyName isEqualToString:@""]) {
        return NO;
    }
    
    NSString *setter = [NSString stringWithFormat:@"set%@:", [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[propertyName substringToIndex:1].uppercaseString]];
    return [self respondsToSelector:NSSelectorFromString(setter)];
}

- (void)setValueForPropertyName:(NSString *)propertyName withDictionary:(NSDictionary *)dictionary
{
    Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:self.class];
    
    if (propertyClass == NULL || [propertyClass isSubclassOfClass:[NSNull class]]) {
        id valueObject = [self initializedObjectForPropertyName:propertyName withData:dictionary];
        if (valueObject != nil) {
            [self setValue:valueObject forKey:propertyName];
        }
    } else if ([propertyClass isSubclassOfClass:[CQKSerializableNSObject class]]) {
        [self setValue:[[propertyClass alloc] initWithDictionary:dictionary] forKey:propertyName];
    } else if ([propertyClass isSubclassOfClass:[NSMutableDictionary class]]) {
        [self setValue:[dictionary mutableCopy] forKey:propertyName];
    } else {
        id valueObject = [self initializedObjectForPropertyName:propertyName withData:dictionary];
        if (valueObject != nil) {
            [self setValue:valueObject forKey:propertyName];
        }
    }
}

- (void)setValueForPropertyName:(NSString *)propertyName withArray:(NSArray *)array
{
    NSMutableArray *value = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id valueObject = [self initializedObjectForPropertyName:propertyName withData:obj];
        if (valueObject != nil) {
            [value addObject:valueObject];
        }
    }];
    
    Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:self.class];
    if ([propertyClass isSubclassOfClass:[NSMutableArray class]]) {
        [self setValue:value forKey:propertyName];
    } else {
        [self setValue:[NSArray arrayWithArray:value] forKey:propertyName];
    }
}

- (void)setValueForPropertyName:(NSString *)propertyName withObject:(id)object
{
    id valueObject = [self initializedObjectForPropertyName:propertyName withData:object];
    if (valueObject != nil) {
        [self setValue:valueObject forKey:propertyName];
    }
}

- (NSArray *)serializedArrayForPropertyName:(NSString *)propertyName withArray:(NSArray *)array
{
    NSMutableArray *serialiazedArray = [NSMutableArray array];
    
    for (id obj in array) {
        if ([[obj class] isSubclassOfClass:[CQKSerializableNSObject class]]) {
            [serialiazedArray addObject:[(CQKSerializableNSObject *)obj dictionary]];
            continue;
        }
        
        id valueObject = [self serializedObjectForPropertyName:propertyName withData:obj];
        if (valueObject != nil) {
            [serialiazedArray addObject:valueObject];
        }
    }
    
    return serialiazedArray;
}

@end
