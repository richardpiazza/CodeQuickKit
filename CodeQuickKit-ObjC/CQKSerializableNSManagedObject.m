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
#import "CQKSerializableConfiguration.h"
#import "CQKLogger.h"

@implementation CQKSerializableNSManagedObject

- (instancetype)initIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    if (entity == nil) {
        NSString *message = [NSString stringWithFormat:@"Failed to create entity description for name: %@ in managed object context: %@", NSStringFromClass(self.class), context];
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

- (nullable NSString *)attributeNameForSerializedKey:(nullable NSString *)serializedKey
{
    return [[CQKSerializableConfiguration sharedConfiguration] propertyNameForSerializedKey:serializedKey];
}

- (nullable NSString *)serializedKeyForAttributeName:(nullable NSString *)attributeName
{
    return [[CQKSerializableConfiguration sharedConfiguration] serializedKeyForPropertyName:attributeName];
}

- (Class)classOfEntityForRelationshipWithAttributeName:(NSString *)attributeName
{
    if (attributeName == nil || [attributeName isEqualToString:@""]) {
        return [NSNull class];
    }
    
    Class entityClass = NSClassFromString(attributeName);
    if (entityClass != nil) {
        return entityClass;
    }
    
    NSMutableString *singular = [attributeName mutableCopy];
    if ([singular.lowercaseString hasSuffix:@"s"]) {
        [singular replaceCharactersInRange:NSMakeRange(singular.length - 1, 1) withString:@""];
    }
    
    [singular replaceCharactersInRange:NSMakeRange(0, 1) withString:[singular substringToIndex:1].uppercaseString];
    
    entityClass = NSClassFromString(singular);
    if (entityClass != nil) {
        return entityClass;
    }
    
    return [NSNull class];
}

- (NSManagedObject *)initializedEntityOfClass:(Class)entityClass forAttributeName:(NSString *)attributeName withDictionary:(NSDictionary *)dictionary
{
    if (entityClass == [NSNull class]) {
        return nil;
    }
    
    if (![entityClass conformsToProtocol:NSProtocolFromString(@"CQKSerializable")]) {
        return nil;
    }
    
    return [[entityClass alloc] initIntoManagedObjectContext:self.managedObjectContext withDictionary:dictionary];
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
        return;
    }
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, __kindof NSObject * _Nonnull data, BOOL * _Nonnull stop) {
        NSString *attributeName = [self attributeNameForSerializedKey:key];
        if (attributeName == nil) {
            return;
        }
        
        Class attributeClass = [NSObject classForPropertyName:attributeName ofClass:self.class];
        if (attributeClass == [NSNull class]) {
            return;
        }
        
        Class dataClass = [data class];
        
        @try {
            if ([dataClass isSubclassOfClass:[NSDictionary class]]) {
                NSManagedObject *object = [self initializedEntityOfClass:attributeClass forAttributeName:attributeName withDictionary:data];
                if (object != nil) {
                    [self setValue:object forKey:attributeName];
                }
            } else if ([dataClass isSubclassOfClass:[NSArray class]]) {
                if (![attributeClass isSubclassOfClass:[NSSet class]]) {
                    return;
                }
                
                Class relationshipAttributeClass = [self classOfEntityForRelationshipWithAttributeName:attributeName];
                
                NSMutableSet *relationshipSet = [[self valueForKey:attributeName] mutableCopy];
                
                [(NSArray *)data enumerateObjectsUsingBlock:^(NSDictionary* relationshipObj, NSUInteger idx, BOOL *stop) {
                    NSManagedObject *object = [self initializedEntityOfClass:relationshipAttributeClass forAttributeName:attributeName withDictionary:relationshipObj];
                    if (object != nil && relationshipSet != nil) {
                        [relationshipSet addObject:object];
                    }
                }];
                
                [self setValue:relationshipSet forKey:attributeName];
            } else {
                [self setValue:data forKey:attributeName];
            }
        }
        @catch (NSException *exception) {
            NSString *message = [NSString stringWithFormat:@"Failed to set value '%@' for attributeName '%@': %@", data, attributeName, exception.reason];
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
        NSString *serializedKey = [self serializedKeyForAttributeName:key];
        if (serializedKey == nil) {
            return;
        }
        
        @try {
            id value = [self valueForKey:key];
            if (value != nil) {
                [dictionary setObject:value forKey:serializedKey];
            }
        }
        @catch (NSException *exception) {
            NSString *message = [NSString stringWithFormat:@"Failed to retrieve value for attributeName '%@': %@", key, exception.reason];
            [CQKLogger log:CQKLoggerLevelException message:message error:nil callingClass:[self class]];
        }
        @finally {
            
        }
    }];
    
    NSDictionary *relationships = [self.entity relationshipsByName];
    [relationships enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        NSString *serializedKey = [self serializedKeyForAttributeName:key];
        if (serializedKey == nil) {
            return;
        }
        
        Class attributeClass = [NSObject classForPropertyName:key ofClass:self.class];
        if ([attributeClass isSubclassOfClass:[NSNull class]]) {
            return;
        }
        
        if ([attributeClass conformsToProtocol:NSProtocolFromString(@"CQKSerializable")]) {
            id <CQKSerializable> serializable = [self valueForKey:key];
            NSDictionary *serializableDictionary = [serializable dictionary];
            if (serializableDictionary != nil) {
                [dictionary setObject:serializableDictionary forKey:serializedKey];
            }
            return;
        }
        
        Class relationshipAttributeClass = [self classOfEntityForRelationshipWithAttributeName:key];
        if ([relationshipAttributeClass isSubclassOfClass:[NSNull class]]) {
            return;
        }
        
        if (![relationshipAttributeClass conformsToProtocol:NSProtocolFromString(@"CQKSerializable")]) {
            return;
        }
        
        NSMutableArray *serializedEntities = [NSMutableArray array];
        
        id <CQKSerializable> serializableSet = [self valueForKey:key];
        if (serializableSet != nil) {
            [(NSSet *)serializableSet enumerateObjectsUsingBlock:^(id<CQKSerializable> obj, BOOL *stop) {
                NSDictionary *serializedDictionary = [obj dictionary];
                if (serializedDictionary != nil) {
                    [serializedEntities addObject:serializedDictionary];
                }
            }];
        }
        
        [dictionary setObject:serializedEntities forKey:serializedKey];
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

@end
