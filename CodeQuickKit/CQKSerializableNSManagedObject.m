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
#import "CQKLogger.h"
#import "NSObject+CQKRuntime.h"

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

- (BOOL)shouldSerializeRelationshipWithAttributeName:(NSString *)attributeName
{
    return YES;
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

#pragma mark - CQKSerializable -
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    [CQKLogger log:CQKLoggerLevelException message:@"initWithDictionary: returning nil; initIntoManagedObjectContext:withDictionary: should be used." error:nil callingClass:self.class];
    return nil;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary == nil || ![dictionary.class isSubclassOfClass:NSDictionary.class]) {
        return;
    }
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, id data, BOOL *stop) {
        Class attributeClass = [NSObject classForPropertyName:attributeName ofClass:self.class];
        if (attributeClass == [NSNull class]) {
            return;
        }
        
        Class dataClass = [data class];
        
        @try {
            if ([dataClass isSubclassOfClass:[NSDictionary class]]) {
                if ([attributeClass conformsToProtocol:NSProtocolFromString(@"CQKSerializable")]) {
                    NSManagedObject *object = [[attributeClass alloc] initIntoManagedObjectContext:self.managedObjectContext withDictionary:data];
                    if (object != nil) {
                        [self setValue:object forKey:attributeName];
                    }
                } else if ([attributeClass isSubclassOfClass:[NSMutableDictionary class]]) {
                    [self setValue:[NSMutableDictionary dictionaryWithDictionary:data] forKey:attributeName];
                } else {
                    [self setValue:data forKey:attributeName];
                }
            } else if ([dataClass isSubclassOfClass:[NSArray class]]) {
                if (![attributeClass isSubclassOfClass:[NSSet class]]) {
                    return;
                }
                
                Class relationshipAttributeClass = [self classOfEntityForRelationshipWithAttributeName:attributeName];
                NSManagedObject *object = [[relationshipAttributeClass alloc] initIntoManagedObjectContext:self.managedObjectContext withDictionary:data];
                if (object != nil) {
                    NSSet *relationshipSet = [self valueForKey:attributeName];
                    [self setValue:[relationshipSet setByAddingObject:object] forKey:attributeName];
                }
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

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSDictionary *attributes = [self.entity attributesByName];
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, id obj, BOOL *stop) {
        @try {
            id value = [self valueForKey:attributeName];
            if (value != nil) {
                [dictionary setObject:value forKey:attributeName];
            }
        }
        @catch (NSException *exception) {
            NSString *message = [NSString stringWithFormat:@"Failed to retrieve value for attributeName '%@': %@", attributeName, exception.reason];
            [CQKLogger log:CQKLoggerLevelException message:message error:nil callingClass:[self class]];
        }
        @finally {
            
        }
    }];
    
    NSDictionary *relationships = [self.entity relationshipsByName];
    [relationships enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, id obj, BOOL *stop) {
        if (![self shouldSerializeRelationshipWithAttributeName:attributeName]) {
            return;
        }
        
        Class attributeClass = [NSObject classForPropertyName:attributeName ofClass:self.class];
        if ([attributeClass isSubclassOfClass:[NSNull class]]) {
            return;
        }
        
        if ([attributeClass conformsToProtocol:NSProtocolFromString(@"CQKSerializable")]) {
            id <CQKSerializable> serializable = [self valueForKey:attributeName];
            NSDictionary *serializableDictionary = [serializable dictionary];
            if (serializableDictionary != nil) {
                [dictionary setObject:serializableDictionary forKey:attributeName];
            }
            return;
        }
        
        Class relationshipAttributeClass = [self classOfEntityForRelationshipWithAttributeName:attributeName];
        if ([relationshipAttributeClass isSubclassOfClass:[NSNull class]]) {
            return;
        }
        
        if (![relationshipAttributeClass conformsToProtocol:NSProtocolFromString(@"CQKSerializable")]) {
            return;
        }
        
        NSMutableArray *serializedEntities = [NSMutableArray array];
        
        id <CQKSerializable> serializableSet = [self valueForKey:attributeName];
        if (serializableSet != nil) {
            [(NSSet *)serializableSet enumerateObjectsUsingBlock:^(id<CQKSerializable> obj, BOOL *stop) {
                NSDictionary *serializedDictionary = [obj dictionary];
                if (serializedDictionary != nil) {
                    [serializedEntities addObject:serializedDictionary];
                }
            }];
        }
        
        [dictionary setObject:serializedEntities forKey:attributeName];
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
