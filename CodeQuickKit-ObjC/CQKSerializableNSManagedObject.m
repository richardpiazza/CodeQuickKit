/*
 *  CQKSerializableNSManagedObject.m
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

#import "CQKSerializableNSManagedObject.h"
#import "NSObject+CQKRuntime.h"
#import "NSBundle+CQKBundle.h"
#import "CQKSerializableConfiguration.h"
#import "CQKLogger.h"

@interface CQKSerializableNSManagedObject ()
- (void)setValueForPropertyName:(nullable NSString *)propertyName withDictionary:(nullable NSDictionary<NSString *, __kindof NSObject *> *)dictionary;
- (void)setValueForPropertyName:(nullable NSString *)propertyName withArray:(nullable NSArray<__kindof NSObject *> *)array;
- (void)setValueForPropertyName:(nullable NSString *)propertyName withObject:(nullable __kindof NSObject *)object;
@end

@implementation CQKSerializableNSManagedObject

- (instancetype)initIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *entityName = self.classNameWithoutModule;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    if (entity == nil) {
        NSString *message = [NSString stringWithFormat:@"Failed to create entity description for name: %@ in managed object context: %@", entityName, context];
        [CQKLogger log:CQKLoggerLevelError message:message error:nil callingClass:self.class];
        return nil;
    }
    
    self = [self initWithEntity:entity insertIntoManagedObjectContext:context];
    return self;
}

- (instancetype)initIntoManagedObjectContext:(NSManagedObjectContext *)context withDictionary:(NSDictionary *)dictionary
{
    self = [self initIntoManagedObjectContext:context];
    if (self != nil) {
        [self updateWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initIntoManagedObjectContext:(NSManagedObjectContext *)context withData:(NSData *)data
{
    self = [self initIntoManagedObjectContext:context];
    if (self != nil) {
        [self updateWithData:data];
    }
    return self;
}

- (instancetype)initIntoManagedObjectContext:(NSManagedObjectContext *)context withJSON:(NSString *)json
{
    self = [self initIntoManagedObjectContext:context];
    if (self != nil) {
        [self updateWithJSON:json];
    }
    return self;
}

#pragma mark - CQKSerializable -
- (instancetype)initWithDictionary:(NSDictionary<NSString *,__kindof NSObject *> *)dictionary
{
    [CQKLogger log:CQKLoggerLevelException message:@"initWithDictionary: returning nil; initIntoManagedObjectContext:withDictionary: should be used." error:nil callingClass:self.class];
    return nil;
}

- (void)updateWithDictionary:(NSDictionary<NSString *,__kindof NSObject *> *)dictionary
{
    if (dictionary == nil || ![dictionary.class isSubclassOfClass:NSDictionary.class]) {
        [CQKLogger log:CQKLoggerLevelWarn message:@"Could not updateWithDictinary:, dictionary is nil." error:nil callingClass:self.class];
        return;
    }
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, __kindof NSObject * _Nonnull data, BOOL * _Nonnull stop) {
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
            if ([[data class] isSubclassOfClass:[NSDictionary class]]) {
                [self setValueForPropertyName:propertyName withDictionary:data];
            } else if ([[data class] isSubclassOfClass:[NSArray class]]) {
                [self setValueForPropertyName:propertyName withArray:data];
            } else if (![[data class] isSubclassOfClass:[NSNull class]]) {
                [self setValueForPropertyName:propertyName withObject:data];
            }
        }
        @catch (NSException *exception) {
            NSString *message = [NSString stringWithFormat:@"Failed to set value '%@' for key '%@': %@", data, key, exception.reason];
            [CQKLogger log:CQKLoggerLevelException message:message error:nil callingClass:[self class]];
        }
        @finally {
        }
    }];
}

- (NSDictionary<NSString *,NSObject *> *)dictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSDictionary *attributes = [self.entity attributesByName];
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
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
            NSString *message = [NSString stringWithFormat:@"Failed to serialize value for attributeName '%@': %@", key, exception.reason];
            [CQKLogger log:CQKLoggerLevelException message:message error:nil callingClass:[self class]];
        }
        @finally {
            
        }
    }];
    
    NSDictionary *relationships = [self.entity relationshipsByName];
    [relationships enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
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
            NSString *message = [NSString stringWithFormat:@"Failed to serialize value for relationshipName '%@': %@", key, exception.reason];
            [CQKLogger log:CQKLoggerLevelException message:message error:nil callingClass:[self class]];
        }
        @finally {
            
        }
    }];
    
    return dictionary;
}

- (instancetype)initWithData:(NSData *)data
{
    [CQKLogger log:CQKLoggerLevelException message:@"initWithData: returning nil; initIntoManagedObjectContext:withData: should be used." error:nil callingClass:self.class];
    return nil;
}

- (void)updateWithData:(NSData *)data
{
    if (data == nil) {
        return;
    }
    
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (dictionary == nil || error != nil) {
        [CQKLogger log:CQKLoggerLevelError message:@"Failed to deserialize data" error:error callingClass:self.class];
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
    
    NSError *error;
    NSData *data;
    
    @try {
        data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        if (data == nil || error != nil) {
            NSString *message = [NSString stringWithFormat:@"Error serializing dictionary: %@", dictionary];
            [CQKLogger log:CQKLoggerLevelError message:message error:error callingClass:self.class];
        }
    }
    @catch (NSException *exception) {
        NSString *message = [NSString stringWithFormat:@"Exception serializing dictionary: %@", dictionary];
        [CQKLogger log:CQKLoggerLevelException message:message error:error callingClass:self.class];
    }
    @finally {
        return data;
    }
}

- (instancetype)initWithJSON:(NSString *)json
{
    [CQKLogger log:CQKLoggerLevelException message:@"initWithJSON: returning nil; initIntoManagedObjectContext:withJSON: should be used." error:nil callingClass:self.class];
    return nil;
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
    return json;
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
    
    if ([propertyClass isSubclassOfClass:[NSSet class]]) {
        Class relationshipClass = [self objectClassOfCollectionTypeForPropertyName:propertyName];
        if ([relationshipClass isSubclassOfClass:[NSNull class]]) {
            return nil;
        }
        
        if (![relationshipClass isSubclassOfClass:[CQKSerializableNSManagedObject class]]) {
            return nil;
        }
        
        return [[relationshipClass alloc] initIntoManagedObjectContext:self.managedObjectContext withDictionary:data];
    } else if ([propertyClass isSubclassOfClass:[CQKSerializableNSManagedObject class]]) {
        return [[propertyClass alloc] initIntoManagedObjectContext:self.managedObjectContext withDictionary:data];
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
    
    if ([[data class] isSubclassOfClass:[NSSet class]]) {
        Class relationshipClass = [self objectClassOfCollectionTypeForPropertyName:propertyName];
        if ([relationshipClass isSubclassOfClass:[NSNull class]]) {
            return nil;
        }
        
        if (![relationshipClass isSubclassOfClass:[CQKSerializableNSManagedObject class]]) {
            return nil;
        }
        
        NSMutableArray *serializedArray = [NSMutableArray array];
        for (CQKSerializableNSManagedObject *cqkObject in (NSSet *)data) {
            [serializedArray addObject:cqkObject.dictionary];
        }
        return serializedArray;
    } else if ([[data class] isSubclassOfClass:[CQKSerializableNSManagedObject class]]) {
        return [(CQKSerializableNSManagedObject *)data dictionary];
    }
    
    return [[CQKSerializableConfiguration sharedConfiguration] serializedObjectForPropertyName:propertyName withData:data];
}

- (Class)objectClassOfCollectionTypeForPropertyName:(NSString *)propertyName
{
    return [NSObject singularizedClassForPropertyName:propertyName];
}

#pragma mark -
- (void)setValueForPropertyName:(NSString *)propertyName withDictionary:(NSDictionary<NSString *,__kindof NSObject *> *)dictionary
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

- (void)setValueForPropertyName:(NSString *)propertyName withArray:(NSArray<__kindof NSObject *> *)array
{
    if (propertyName == nil || array == nil) {
        return;
    }
    
    Class propertyClass = [NSObject classForPropertyName:propertyName ofClass:self.class];
    if (propertyClass == [NSNull class] || ![propertyClass isSubclassOfClass:[NSSet class]]) {
        return;
    }
    
    NSMutableSet *relationshipSet = [[self valueForKey:propertyName] mutableCopy];
    [array enumerateObjectsUsingBlock:^(__kindof NSObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSManagedObject *initializedObject = [self initializedObjectForPropertyName:propertyName withData:obj];
        if (initializedObject != nil) {
            [relationshipSet addObject:initializedObject];
        }
    }];
    
    [self setValue:relationshipSet forKey:propertyName];
}

- (void)setValueForPropertyName:(NSString *)propertyName withObject:(__kindof NSObject *)object
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
