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
#import <objc/runtime.h>
#import "CQKLogger.h"

@implementation CQKSerializableNSObjectConfiguration

- (id)init
{
    self = [super init];
    if (self != nil) {
        [self setPropertyKeyStyle:CQKSerializableNSObjectKeyStyleMatchCase];
        [self setSerializedKeyStyle:CQKSerializableNSObjectKeyStyleMatchCase];
        [self setSerializedIDPropertyName:nil];
        [self setSerializedNSDateFormatter:[[NSDateFormatter alloc] init]];
        [self.serializedNSDateFormatter setDateFormat:CQKSerializableNSObjectDateFormat];
        [self setVerboseLogging:NO];
    }
    return self;
}

@end

@interface CQKSerializableNSObject ()
+ (NSString *)stringForPropertyName:(NSString *)propertyName withKeyStyle:(CQKSerializableNSObjectKeyStyle)keyStyle;
+ (NSString *)jsonStringRemovingPrettyFormatting:(NSString *)json;
- (BOOL)respondsToSetterForPropertyName:(NSString *)propertyName;
- (void)setValueForPropertyName:(NSString *)propertyName withDictionary:(NSDictionary *)dictionary;
- (void)setValueForPropertyName:(NSString *)propertyName withArray:(NSArray *)array;
- (void)setValueForPropertyName:(NSString *)propertyName withObject:(id)object;
- (NSArray *)serializedArrayForPropertyName:(NSString *)propertyName withArray:(NSArray *)array;
- (NSArray *)propertyNamesForClass;
- (Class)classForPropertyName:(NSString *)propertyName;
@end

@implementation CQKSerializableNSObject

+ (CQKSerializableNSObjectConfiguration *)configuration
{
    static CQKSerializableNSObjectConfiguration *_configuration;
    if (_configuration != nil) {
        return _configuration;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _configuration = [[CQKSerializableNSObjectConfiguration alloc] init];
    });
    
    return _configuration;
}

+ (NSString *)stringForPropertyName:(NSString *)propertyName withKeyStyle:(CQKSerializableNSObjectKeyStyle)keyStyle
{
    if (propertyName == nil || [propertyName isEqualToString:@""]) {
        return nil;
    }
    
    if (propertyName.length == 1) {
        return propertyName;
    }
    
    switch (keyStyle) {
        case CQKSerializableNSObjectKeyStyleMatchCase: {
            return propertyName;
        }
        case CQKSerializableNSObjectKeyStyleCamelCase: {
            return [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyName substringToIndex:1] lowercaseString]];
        }
        case CQKSerializableNSObjectKeyStyleTitleCase: {
            return [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyName substringToIndex:1] uppercaseString]];
        }
        case CQKSerializableNSObjectKeyStyleUpperCase: {
            return propertyName.uppercaseString;
        }
        case CQKSerializableNSObjectKeyStyleLowerCase: {
            return propertyName.lowercaseString;
        }
        default: {
            return propertyName;
        }
    }
}

+ (NSString *)jsonStringRemovingPrettyFormatting:(NSString *)json
{
    NSMutableString *jsonString = [NSMutableString stringWithString:json];
    [jsonString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, jsonString.length)];
    [jsonString replaceOccurrencesOfString:@" : " withString:@":" options:NSCaseInsensitiveSearch range:NSMakeRange(0, jsonString.length)];
    [jsonString replaceOccurrencesOfString:@"  " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, jsonString.length)];
    [jsonString replaceOccurrencesOfString:@"\\/" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, jsonString.length)];
    return jsonString;
}

#pragma mark - NSCoding -
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self != nil) {
        
        NSArray *classProperties = [self propertyNamesForClass];
        
        for (NSString *propertyName in classProperties) {
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
    NSArray *classProperties = [self propertyNamesForClass];
    
    for (NSString *propertyName in classProperties) {
        if (![self respondsToSelector:NSSelectorFromString(propertyName)]) {
            continue;
        }
        
        Class propertyClass = [self classForPropertyName:propertyName];
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

#pragma mark - CQKSerializableNSObjectProtocol -
- (NSString *)propertyNameForSerializedKey:(NSString *)serializedKey
{
    if ([serializedKey.lowercaseString isEqualToString:CQKSerializableNSObjectIDPropertyName.lowercaseString]) {
        if ([[CQKSerializableNSObject configuration] serializedIDPropertyName] != nil) {
            return [[CQKSerializableNSObject configuration] serializedIDPropertyName];
        } else {
            NSArray *propertyNames = [CQKSerializableNSObject propertyNamesForClass:[self class]];
            if ([propertyNames containsObject:CQKSerializableNSObjectUUIDPropertyName]) {
                return CQKSerializableNSObjectUUIDPropertyName;
            } else if ([propertyNames containsObject:CQKSerializableNSObjectUniqueIdPropertyName]) {
                return CQKSerializableNSObjectUniqueIdPropertyName;
            }
        }
    }
    
    return [self.class stringForPropertyName:serializedKey withKeyStyle:[[CQKSerializableNSObject configuration] propertyKeyStyle]];
}

- (NSString *)serializedKeyForPropertyName:(NSString *)propertyName
{
    if ([[CQKSerializableNSObject configuration] serializedIDPropertyName] != nil) {
        if ([propertyName isEqualToString:[[CQKSerializableNSObject configuration] serializedIDPropertyName]]) {
            return [self.class stringForPropertyName:CQKSerializableNSObjectIDPropertyName withKeyStyle:[[CQKSerializableNSObject configuration] serializedKeyStyle]];
        }
    } else {
        if ([propertyName isEqualToString:CQKSerializableNSObjectUUIDPropertyName]) {
            return [self.class stringForPropertyName:CQKSerializableNSObjectIDPropertyName withKeyStyle:[[CQKSerializableNSObject configuration] serializedKeyStyle]];
        } else if ([propertyName isEqualToString:CQKSerializableNSObjectUniqueIdPropertyName]) {
            return [self.class stringForPropertyName:CQKSerializableNSObjectIDPropertyName withKeyStyle:[[CQKSerializableNSObject configuration] serializedKeyStyle]];
        }
    }
    
    return [self.class stringForPropertyName:propertyName withKeyStyle:[[CQKSerializableNSObject configuration] serializedKeyStyle]];
}

- (id <NSObject>)initializedObjectForPropertyName:(NSString *)propertyName withData:(id)data
{
    Class propertyClass = [self classForPropertyName:propertyName];
    
    if ([propertyClass isSubclassOfClass:[NSUUID class]]) {
        return [[NSUUID alloc] initWithUUIDString:(NSString *)data];
    } else if ([propertyClass isSubclassOfClass:[NSDate class]]) {
        return [[[CQKSerializableNSObject configuration] serializedNSDateFormatter] dateFromString:(NSString *)data];
    } else if ([propertyClass isSubclassOfClass:[NSURL class]]) {
        return [NSURL URLWithString:(NSString *)data];
    }
    
    return data;
}

- (id <NSObject>)serializedObjectForPropertyName:(NSString *)propertyName withData:(id)data
{
    if ([[data class] isSubclassOfClass:[NSUUID class]]) {
        return [(NSUUID *)data UUIDString];
    } else if ([[data class] isSubclassOfClass:[NSDate class]]) {
        return [[[CQKSerializableNSObject configuration] serializedNSDateFormatter] stringFromDate:(NSDate *)data];
    } else if ([[data class] isSubclassOfClass:[NSURL class]]) {
        return [(NSURL *)data absoluteString];
    }
    
    return data;
}

#pragma mark - CQKSerializableNSObject -
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self != nil) {
        [self updateWithDictionary:dictionary];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary == nil || ![[dictionary class] isSubclassOfClass:[NSDictionary class]]) {
        return;
    }
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *propertyName = [self propertyNameForSerializedKey:key];
        if (propertyName == nil) {
            return;
        }
        
        if (![self respondsToSetterForPropertyName:propertyName]) {
            if ([[CQKSerializableNSObject configuration] verboseLogging]) {
                NSString *message = [NSString stringWithFormat:@"%s[%@] Responds to setter = NO", __PRETTY_FUNCTION__, propertyName];
                [CQKLogger log:CQKLoggerLevelDebug message:message error:nil callingClass:[self class]];
            }
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

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSArray *properties = [self propertyNamesForClass];
    for (NSString *propertyName in properties) {
        if (![self respondsToSelector:NSSelectorFromString(propertyName)]) {
            if ([[CQKSerializableNSObject configuration] verboseLogging]) {
                NSString *message = [NSString stringWithFormat:@"%s[%@] Responds to selector = NO", __PRETTY_FUNCTION__, propertyName];
                [CQKLogger log:CQKLoggerLevelDebug message:message error:nil callingClass:[self class]];
            }
            continue;
        }
        
        id valueObject = [self valueForKey:propertyName];
        if (valueObject == nil) {
            if ([[CQKSerializableNSObject configuration] verboseLogging]) {
                NSString *message = [NSString stringWithFormat:@"%s[%@] value = nil", __PRETTY_FUNCTION__, propertyName];
                [CQKLogger log:CQKLoggerLevelDebug message:message error:nil callingClass:[self class]];
            }
            continue;
        }
        
        Class propertyClass = [self classForPropertyName:propertyName];
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

- (id <CQKSerializableNSObjectProtocol>)initWithData:(NSData *)data;
{
    self = [self init];
    if (self != nil) {
        [self updateWithData:data];
    }
    return self;
}

- (void)updateWithData:(NSData *)data
{
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (dictionary == nil || error != nil) {
        NSString *message = [NSString stringWithFormat:@"Failed to update with data '%@'", data];
        [CQKLogger log:CQKLoggerLevelError message:message error:error callingClass:[self class]];
        return;
    }
    
    [self updateWithDictionary:dictionary];
}

- (NSData *)data
{
    NSDictionary *dictionary = self.dictionary;
    if (dictionary == nil) {
        return nil;
    }
    
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

- (id)initWithJSON:(NSString *)json
{
    self = [self init];
    if (self != nil) {
        [self updateWithJSON:json];
    }
    return self;
}

- (void)updateWithJSON:(NSString *)json
{
    if (json == nil || [json isEqualToString:@""]) {
        return;
    }
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        return;
    }
    
    [self updateWithData:data];
}

- (NSString *)json
{
    NSData *data = self.data;
    if (data == nil) {
        return nil;
    }
    
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *jsonFormatted = [CQKSerializableNSObject jsonStringRemovingPrettyFormatting:json];
    return jsonFormatted;
}

#pragma mark -
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
    Class propertyClass = [self classForPropertyName:propertyName];
    
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
    
    Class propertyClass = [self classForPropertyName:propertyName];
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

#pragma mark - ObjC Runtime -
+ (NSArray *)propertyNamesForClass:(Class)objectClass
{
    NSMutableArray *properties = [NSMutableArray array];
    
    if ([[objectClass superclass] isSubclassOfClass:[CQKSerializableNSObject class]]) {
        NSArray *superProperties = [CQKSerializableNSObject propertyNamesForClass:[objectClass superclass]];
        [properties addObjectsFromArray:superProperties];
    }
    
    unsigned int propertyListCount;
    objc_property_t *runtimeProperties = class_copyPropertyList(objectClass, &propertyListCount);
    for (unsigned int i = 0; i < propertyListCount; i++) {
        objc_property_t runtimeProperty = runtimeProperties[i];
        const char *runtimeName = property_getName(runtimeProperty);
        NSString *propertyName = [NSString stringWithUTF8String:runtimeName];
        [properties addObject:propertyName];
    }
    free(runtimeProperties);
    
    [properties removeObject:@"superclass"];
    [properties removeObject:@"hash"];
    [properties removeObject:@"description"];
    [properties removeObject:@"debugDescription"];
    
    return properties;
}

- (NSArray *)propertyNamesForClass
{
    NSArray *propertyNames = [CQKSerializableNSObject propertyNamesForClass:self.class];
    return propertyNames;
}

+ (Class)classForPropertyName:(NSString *)propertyName ofClass:(Class)objectClass
{
    if (propertyName == nil || [propertyName isEqualToString:@""]) {
        return [NSNull class];
    }
    
    objc_property_t runtimeProperty = class_getProperty(objectClass, propertyName.UTF8String);
    if (runtimeProperty == nil) {
        return [NSNull class];
    }
    
    const char *runtimeAttributes = property_getAttributes(runtimeProperty);
    NSString *propertyAttributesString = [NSString stringWithUTF8String:runtimeAttributes];
    NSArray *propertyAttributesCollection = [propertyAttributesString componentsSeparatedByString:@","];
    NSString *propertyClassAttribute = [propertyAttributesCollection objectAtIndex:0];
    if ([propertyClassAttribute length] == 2) {
        // MAYBE A SWIFT CLASS?
        NSString *type = [propertyClassAttribute substringFromIndex:1];
        if ([type isEqualToString:@"q"]) {
            return [NSNumber class]; //Int
        } else if ([type isEqualToString:@"f"]) {
            return [NSNumber class]; //Float
        } else if ([type isEqualToString:@"B"]) {
            return [NSNumber class]; //Boolean
        } else if ([type isEqualToString:@"@"]) {
            return [NSObject class];
        }
        
        if ([[CQKSerializableNSObject configuration] verboseLogging]) {
            NSString *message = [NSString stringWithFormat:@"%s[%@,%@]", __PRETTY_FUNCTION__, propertyName, propertyAttributesCollection];
            [CQKLogger log:CQKLoggerLevelDebug message:message error:nil callingClass:[self class]];
        }
        
        return [NSObject class];
    }
    
    NSString *propertyClass = [propertyClassAttribute substringFromIndex:1];
    NSString *class = [propertyClass substringWithRange:NSMakeRange(2, propertyClass.length - 3)];
    return NSClassFromString(class);
}

- (Class)classForPropertyName:(NSString *)propertyName
{
    Class aClass = [CQKSerializableNSObject classForPropertyName:propertyName ofClass:self.class];
    return aClass;
}

@end

NSString * const CQKSerializableNSObjectDateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
NSString * const CQKSerializableNSObjectUUIDPropertyName = @"uuid";
NSString * const CQKSerializableNSObjectUniqueIdPropertyName = @"uniqueId";
NSString * const CQKSerializableNSObjectIDPropertyName = @"id";
