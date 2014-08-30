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

@interface CQKSerializableNSObjectFormatOptions : NSObject
@property (nonatomic) CQKSerializableNSObjectKeyStyle propertyKeyStyle;
@property (nonatomic) CQKSerializableNSObjectKeyStyle serializedKeyStyle;
@property (nonatomic, strong) NSString *serializedIDPropertyName;
@property (nonatomic) BOOL logActivity;
@property (nonatomic, strong) NSDateFormatter *serializedNSDateFormatter;
@end

@implementation CQKSerializableNSObjectFormatOptions
- (id)init
{
    self = [super init];
    if (self != nil) {
        _propertyKeyStyle = CQKSerializableNSObjectKeyStyleCamelCase;
        _serializedKeyStyle = CQKSerializableNSObjectKeyStyleTitleCase;
        _serializedIDPropertyName = CQKSerializableNSObjectUUIDPropertyName;
        _logActivity = NO;
        _serializedNSDateFormatter = [[NSDateFormatter alloc] init];
        [_serializedNSDateFormatter setDateFormat:CQKSerializableNSObjectDateFormat];
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

+ (CQKSerializableNSObjectFormatOptions *)formatOptions
{
    static CQKSerializableNSObjectFormatOptions *_formatOptions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _formatOptions = [[CQKSerializableNSObjectFormatOptions alloc] init];
    });
    return _formatOptions;
}

+ (void)setPropertyKeyStyle:(CQKSerializableNSObjectKeyStyle)keyStyle
{
    [[CQKSerializableNSObject formatOptions] setPropertyKeyStyle:keyStyle];
}

+ (void)setSerializedKeyStyle:(CQKSerializableNSObjectKeyStyle)keyStyle
{
    [[CQKSerializableNSObject formatOptions] setSerializedKeyStyle:keyStyle];
}

+ (void)setSerializedIDPropertyName:(NSString *)propertyName
{
    [[CQKSerializableNSObject formatOptions] setSerializedIDPropertyName:propertyName];
}

+ (void)setLogActivity:(BOOL)logActivity
{
    [[CQKSerializableNSObject formatOptions] setLogActivity:logActivity];
}

+ (NSString *)stringForPropertyName:(NSString *)propertyName withKeyStyle:(CQKSerializableNSObjectKeyStyle)keyStyle
{
    if (propertyName == nil || [propertyName isEqualToString:@""])
        return nil;
    
    if (propertyName.length == 1)
        return propertyName;
    
    switch (keyStyle) {
        case CQKSerializableNSObjectKeyStyleCamelCase:
            return [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyName substringToIndex:1] lowercaseString]];
        case CQKSerializableNSObjectKeyStyleTitleCase:
            return [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyName substringToIndex:1] uppercaseString]];
        case CQKSerializableNSObjectKeyStyleUpperCase:
            return propertyName.uppercaseString;
        case CQKSerializableNSObjectKeyStyleLowerCase:
            return propertyName.lowercaseString;
        default:
            return propertyName;
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
            if (![self respondsToSetterForPropertyName:propertyName])
                continue;
            
            if (![decoder containsValueForKey:propertyName])
                continue;
            
            [self setValue:[decoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    NSArray *classProperties = [self propertyNamesForClass];
    
    for (NSString *propertyName in classProperties) {
        if (![self respondsToSelector:NSSelectorFromString(propertyName)])
            continue;
        
        Class propertyClass = [self classForPropertyName:propertyName];
        if (![propertyClass isSubclassOfClass:[NSObject class]])
            continue;
        
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
    if ([serializedKey.lowercaseString isEqualToString:CQKSerializableNSObjectIDSerializedKey.lowercaseString]) {
        if ([[CQKSerializableNSObject formatOptions] serializedIDPropertyName] != nil) {
            return [[CQKSerializableNSObject formatOptions] serializedIDPropertyName];
        }
    }
    
    return [self.class stringForPropertyName:serializedKey withKeyStyle:[[CQKSerializableNSObject formatOptions] propertyKeyStyle]];
}

- (NSString *)serializedKeyForPropertyName:(NSString *)propertyName
{
    if ([[CQKSerializableNSObject formatOptions] serializedIDPropertyName] != nil) {
        if ([propertyName isEqualToString:[[CQKSerializableNSObject formatOptions] serializedIDPropertyName]]) {
            return [self.class stringForPropertyName:CQKSerializableNSObjectIDSerializedKey withKeyStyle:[[CQKSerializableNSObject formatOptions] serializedKeyStyle]];
        }
    }
    
    return [self.class stringForPropertyName:propertyName withKeyStyle:[[CQKSerializableNSObject formatOptions] serializedKeyStyle]];
}

- (id <NSObject>)initializedObjectForPropertyName:(NSString *)propertyName withData:(id)data
{
    Class propertyClass = [self classForPropertyName:propertyName];
    
    if ([propertyClass isSubclassOfClass:[NSUUID class]]) {
        return [[NSUUID alloc] initWithUUIDString:(NSString *)data];
    } else if ([propertyClass isSubclassOfClass:[NSDate class]]) {
        return [[[CQKSerializableNSObject formatOptions] serializedNSDateFormatter] dateFromString:(NSString *)data];
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
        return [[[CQKSerializableNSObject formatOptions] serializedNSDateFormatter] stringFromDate:(NSDate *)data];
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
    if (dictionary == nil || ![[dictionary class] isSubclassOfClass:[NSDictionary class]])
        return;
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *propertyName = [self propertyNameForSerializedKey:key];
        if (propertyName == nil)
            return;
        
        if (![self respondsToSetterForPropertyName:propertyName])
            return;
        
        @try {
            if ([[obj class] isSubclassOfClass:[NSDictionary class]])
                [self setValueForPropertyName:propertyName withDictionary:obj];
            else if ([[obj class] isSubclassOfClass:[NSArray class]])
                [self setValueForPropertyName:propertyName withArray:obj];
            else if (![[obj class] isSubclassOfClass:[NSNull class]])
                [self setValueForPropertyName:propertyName withObject:obj];
        }
        @catch (NSException *exception) {
            NSLog(@"%@ %s\nFailed to set Value: %@ For Key: %@ (%@)\nException: %@", NSStringFromClass([self class]), __PRETTY_FUNCTION__, obj, key, propertyName, exception);
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
        if (![self respondsToSelector:NSSelectorFromString(propertyName)])
            continue;
        
        id valueObject = [self valueForKey:propertyName];
        if (valueObject == nil)
            continue;
        
        Class propertyClass = [self classForPropertyName:propertyName];
        NSString *serializedKey = [self serializedKeyForPropertyName:propertyName];
        
        @try {
            if ([propertyClass isSubclassOfClass:[CQKSerializableNSObject class]])
                [dictionary setObject:[(CQKSerializableNSObject *)valueObject dictionary] forKey:serializedKey];
            else if ([propertyClass isSubclassOfClass:[NSArray class]])
                [dictionary setObject:[self serializedArrayForPropertyName:propertyName withArray:valueObject] forKey:serializedKey];
            else {
                id serializedObject = [self serializedObjectForPropertyName:propertyName withData:valueObject];
                if (serializedObject != nil)
                    [dictionary setObject:serializedObject forKey:serializedKey];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@ %s\nFailed to set Value: %@ For Key: %@ (%@)\nException: %@", NSStringFromClass([self class]), __PRETTY_FUNCTION__, valueObject, propertyName, serializedKey, exception);
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
        NSLog(@"%@ %s Failed with Data: %@; Error: %@", NSStringFromClass([self class]), __PRETTY_FUNCTION__, data, error);
        return;
    }
    
    [self updateWithDictionary:dictionary];
}

- (NSData *)data
{
    NSDictionary *dictionary = self.dictionary;
    if (dictionary == nil)
        return nil;
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (data == nil || error != nil) {
        NSLog(@"%@ %s Failed with dictionary: %@; Error: %@", NSStringFromClass([self class]), __PRETTY_FUNCTION__, dictionary, error);
        return nil;
    }
    
    return data;
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
    if (json == nil || [json isEqualToString:@""])
        return;
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil)
        return;
    
    [self updateWithData:data];
}

- (NSString *)json
{
    NSData *data = self.data;
    if (data == nil)
        return nil;
    
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *jsonFormatted = [CQKSerializableNSObject jsonStringRemovingPrettyFormatting:json];
    return jsonFormatted;
}

#pragma mark -
- (BOOL)respondsToSetterForPropertyName:(NSString *)propertyName
{
    if (propertyName == nil || [propertyName isEqualToString:@""])
        return NO;
    
    NSString *setter = [NSString stringWithFormat:@"set%@:", [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[propertyName substringToIndex:1].uppercaseString]];
    return [self respondsToSelector:NSSelectorFromString(setter)];
}

- (void)setValueForPropertyName:(NSString *)propertyName withDictionary:(NSDictionary *)dictionary
{
    Class propertyClass = [self classForPropertyName:propertyName];
    
    if ([propertyClass isSubclassOfClass:[CQKSerializableNSObject class]])
        [self setValue:[[propertyClass alloc] initWithDictionary:dictionary] forKey:propertyName];
    else if ([propertyClass isSubclassOfClass:[NSMutableDictionary class]])
        [self setValue:[dictionary mutableCopy] forKey:propertyName];
    else
        [self setValue:dictionary forKey:propertyName];
}

- (void)setValueForPropertyName:(NSString *)propertyName withArray:(NSArray *)array
{
    NSMutableArray *value = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id valueObject = [self initializedObjectForPropertyName:propertyName withData:obj];
        if (valueObject != nil)
            [value addObject:valueObject];
    }];
    
    Class propertyClass = [self classForPropertyName:propertyName];
    if ([propertyClass isSubclassOfClass:[NSMutableArray class]])
        [self setValue:value forKey:propertyName];
    else
        [self setValue:[NSArray arrayWithArray:value] forKey:propertyName];
}

- (void)setValueForPropertyName:(NSString *)propertyName withObject:(id)object
{
    id valueObject = [self initializedObjectForPropertyName:propertyName withData:object];
    if (valueObject != nil)
        [self setValue:valueObject forKey:propertyName];
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
        if (valueObject != nil)
            [serialiazedArray addObject:valueObject];
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
    return [CQKSerializableNSObject propertyNamesForClass:self.class];
}

+ (Class)classForPropertyName:(NSString *)propertyName ofClass:(Class)objectClass
{
    if (propertyName == nil || [propertyName isEqualToString:@""])
        return [NSNull class];
    
    objc_property_t runtimeProperty = class_getProperty(objectClass, propertyName.UTF8String);
    if (runtimeProperty == nil)
        return [NSNull class];
    
    const char *runtimeAttributes = property_getAttributes(runtimeProperty);
    NSString *propertyAttributesString = [NSString stringWithUTF8String:runtimeAttributes];
    NSArray *propertyAttributesCollection = [propertyAttributesString componentsSeparatedByString:@","];
    NSString *propertyClassAttribute = [propertyAttributesCollection objectAtIndex:0];
    if ([propertyClassAttribute length] == 2)
        return [NSObject class];
    
    NSString *propertyClass = [propertyClassAttribute substringFromIndex:1];
    NSString *class = [propertyClass substringWithRange:NSMakeRange(2, propertyClass.length - 3)];
    return NSClassFromString(class);
}

- (Class)classForPropertyName:(NSString *)propertyName
{
    return [CQKSerializableNSObject classForPropertyName:propertyName ofClass:self.class];
}

@end

NSString * const CQKSerializableNSObjectDateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
NSString * const CQKSerializableNSObjectUUIDPropertyName = @"uuid";
NSString * const CQKSerializableNSObjectUniqueIdPropertyName = @"uniqueId";
NSString * const CQKSerializableNSObjectIDSerializedKey = @"Id";
