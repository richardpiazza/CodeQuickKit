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
#import "NSBundle+CQKBundle.h"
#import "NSDateFormatter+CQKDateFormatter.h"
#import "CQKSerializableConfiguration.h"
#import "CQKLogger.h"

@interface CQKSerializableNSObject ()
- (void)setValueForPropertyName:(NSString *)propertyName withDictionary:(NSDictionary *)dictionary;
- (void)setValueForPropertyName:(NSString *)propertyName withArray:(NSArray *)array;
- (void)setValueForPropertyName:(NSString *)propertyName withSet:(NSSet *)set;
- (void)setValueForPropertyName:(NSString *)propertyName withObject:(id)object;
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
- (nonnull instancetype)initWithDictionary:(NSDictionary<NSString *,__kindof NSObject *> *)dictionary
{
    self = [self init];
    if (self != nil) {
        [self updateWithDictionary:dictionary];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary<NSString *,__kindof NSObject *> *)dictionary
{
    if (dictionary == nil || ![[dictionary class] isSubclassOfClass:[NSDictionary class]]) {
        [CQKLogger log:CQKLoggerLevelWarn message:@"Could not updateWithDictinary:, dictionary is nil." error:nil callingClass:self.class];
        return;
    }
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, __kindof NSObject * _Nonnull obj, BOOL * _Nonnull stop) {
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

- (NSDictionary<NSString *,NSObject *> *)dictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSArray *properties = [NSObject propertyNamesForClass:self.class];
    [properties enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *serializedKey = [self serializedKeyForPropertyName:key];
        if (serializedKey == nil) {
            return;
        }
        
        @try {
            id value = [self valueForKey:key];
            if (value == nil) {
                return;
            }
            
            NSObject *serializedValue = [self serializedObjectForPropertyName:key withData:value];
            if (serializedValue == nil) {
                return;
            }
            
            [dictionary setObject:serializedValue forKey:serializedKey];
        }
        @catch (NSException *exception) {
            NSString *message = [NSString stringWithFormat:@"Failed to serialize value for propertyName '%@': %@", key, exception.reason];
            [CQKLogger log:CQKLoggerLevelException message:message error:nil callingClass:[self class]];
        }
        @finally {
            
        }
    }];
    
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
        NSString *message = [NSString stringWithFormat:@"Failed to serialize dictionary %@\n%@", dictionary, exception.reason];
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

#pragma mark - CQKSerializableCustomizable -
- (NSString *)propertyNameForSerializedKey:(NSString *)serializedKey
{
    return [[CQKSerializableConfiguration sharedConfiguration] propertyNameForSerializedKey:serializedKey];
}

- (NSString *)serializedKeyForPropertyName:(NSString *)propertyName
{
    return [[CQKSerializableConfiguration sharedConfiguration] serializedKeyForPropertyName:propertyName];
}

- (NSObject *)initializedObjectForPropertyName:(NSString *)propertyName withData:(__kindof NSObject *)data
{
    if (propertyName == nil || data == nil) {
        return nil;
    }
    
    Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:self.class];
    if (propertyClass == [NSNull class]) {
        return nil;
    }
    
    if ([propertyClass isSubclassOfClass:[NSArray class]]) {
        Class containingClass = [self objectClassOfCollectionTypeForPropertyName:propertyName];
        if ([containingClass isSubclassOfClass:[NSNull class]]) {
            return nil;
        }
        
        if ([containingClass isSubclassOfClass:[CQKSerializableNSObject class]]) {
            return [[containingClass alloc] initWithDictionary:data];
        }
    } else if ([propertyClass isSubclassOfClass:[NSSet class]]) {
        Class containingClass = [self objectClassOfCollectionTypeForPropertyName:propertyName];
        if ([containingClass isSubclassOfClass:[NSNull class]]) {
            return nil;
        }
        
        if ([containingClass isSubclassOfClass:[CQKSerializableNSObject class]]) {
            return [[containingClass alloc] initWithDictionary:data];
        }
    } else if ([propertyClass isSubclassOfClass:[CQKSerializableNSObject class]]) {
        return [[propertyClass alloc] initWithDictionary:data];
    } else if ([propertyClass isSubclassOfClass:[NSMutableDictionary class]]) {
        return [data mutableCopy];
    } else if ([propertyClass isSubclassOfClass:[NSDictionary class]]) {
        return data;
    }
    
    return [[CQKSerializableConfiguration sharedConfiguration] initializedObjectForPropertyName:propertyName ofClass:self.class withData:data];
}

- (NSObject *)serializedObjectForPropertyName:(NSString *)propertyName withData:(__kindof NSObject *)data
{
    if (propertyName == nil || data == nil) {
        return nil;
    }
    
    Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:self.class];
    if (propertyClass == [NSNull class]) {
        return nil;
    }
    
    if ([[data class] isSubclassOfClass:[NSArray class]]) {
        NSMutableArray *serializedArray = [NSMutableArray array];
        for (id obj in (NSArray *)data) {
            if ([[obj class] isSubclassOfClass:[CQKSerializableNSObject class]]) {
                [serializedArray addObject:[(CQKSerializableNSObject *)obj dictionary]];
            } else if ([[obj class] isSubclassOfClass:[NSObject class]]) {
                NSObject *serializedObject = [self serializedObjectForPropertyName:propertyName withData:obj];
                if (serializedObject != nil) {
                    [serializedArray addObject:serializedObject];
                }
            }
        }
        return serializedArray;
    } else if ([[data class] isSubclassOfClass:[NSSet class]]) {
        NSMutableSet *serializedSet = [NSMutableSet set];
        for (id obj in (NSSet *)data) {
            if ([[obj class] isSubclassOfClass:[CQKSerializableNSObject class]]) {
                [serializedSet addObject:[(CQKSerializableNSObject *)obj dictionary]];
            } else if ([[obj class] isSubclassOfClass:[NSObject class]]) {
                NSObject *serializedObject = [self serializedObjectForPropertyName:propertyName withData:obj];
                if (serializedObject != nil) {
                    [serializedSet addObject:serializedObject];
                }
            }
        }
        return serializedSet;
    } else if ([[data class] isSubclassOfClass:[CQKSerializableNSObject class]]) {
        return [(CQKSerializableNSObject *)data dictionary];
    }
    
    return [[CQKSerializableConfiguration sharedConfiguration] serializedObjectForPropertyName:propertyName withData:data];
}

- (Class)objectClassOfCollectionTypeForPropertyName:(NSString *)propertyName
{
    return [NSObject singularizedClassForPropertyName:propertyName inBundle:[NSBundle bundleForClass:self.class]];
}

#pragma mark -
- (void)setValueForPropertyName:(NSString *)propertyName withDictionary:(NSDictionary *)dictionary
{
    if (propertyName == nil || dictionary == nil) {
        return;
    }
    
    NSObject *initializedObject = [self initializedObjectForPropertyName:propertyName withData:dictionary];
    if (initializedObject == nil) {
        return;
    }
    
    [self setValue:initializedObject forKey:propertyName];
}

- (void)setValueForPropertyName:(NSString *)propertyName withArray:(NSArray *)array
{
    if (propertyName == nil || array == nil) {
        return;
    }
    
    Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:self.class];
    if (propertyClass == [NSNull class]) {
        return;
    }
    
    NSMutableArray *initializedArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSObject *initializedObject = [self initializedObjectForPropertyName:propertyName withData:obj];
        if (initializedObject != nil) {
            [initializedArray addObject:initializedObject];
        }
    }];
    
    if ([propertyClass isSubclassOfClass:[NSMutableArray class]]) {
        [self setValue:initializedArray forKey:propertyName];
    } else {
        [self setValue:[NSArray arrayWithArray:initializedArray] forKey:propertyName];
    }
}

- (void)setValueForPropertyName:(NSString *)propertyName withSet:(NSSet *)set
{
    if (propertyName == nil || set == nil) {
        return;
    }
    
    Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:self.class];
    if (propertyClass == [NSNull class]) {
        return;
    }
    
    NSMutableSet *initializedSet = [NSMutableSet set];
    [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSObject *initializedObject = [self initializedObjectForPropertyName:propertyName withData:obj];
        if (initializedObject != nil) {
            [initializedSet addObject:initializedObject];
        }
    }];
    
    if ([propertyClass isSubclassOfClass:[NSMutableSet class]]) {
        [self setValue:initializedSet forKey:propertyName];
    } else {
        [self setValue:[NSSet setWithSet:initializedSet] forKey:propertyName];
    }
}

- (void)setValueForPropertyName:(NSString *)propertyName withObject:(id)object
{
    if (propertyName == nil || object == nil) {
        return;
    }
    
    NSObject *initializedObject = [self initializedObjectForPropertyName:propertyName withData:object];
    if (initializedObject == nil) {
        return;
    }
    
    [self setValue:initializedObject forKey:propertyName];
}

@end
