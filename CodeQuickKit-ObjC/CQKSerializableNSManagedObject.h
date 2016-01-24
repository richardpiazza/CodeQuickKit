/*
 *  CQKSerializableNSManagedObject.h
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
#import <CoreData/CoreData.h>
#import "CQKSerializable.h"

@interface CQKSerializableNSManagedObject : NSManagedObject <CQKSerializable>

/*!
 @abstract      Initialize a new NSManagedObject into the provided NSManagedObjectContext.
 @discussion    This method assumes that an NSEntityDescription exists within the NSManagedObjectContext
                that has the exact name of the class. i.e. If the class name is "Person", a "Person" entity must
                exist in the model.
 @property      context The NSManagedObjectContext with the matching entity description.
 @return        A NSManagedObject subclass that has been inserted into the NSManagedObjectContext.
 */
- (nullable instancetype)initIntoManagedObjectContext:(nonnull NSManagedObjectContext *)context;
/*! @abstract  Calls the default initializer then passes the referenced dictionary to `CQKSerializable` updateWithDictionary:. */
- (nullable instancetype)initIntoManagedObjectContext:(nonnull NSManagedObjectContext *)context withDictionary:(nullable NSDictionary<NSString *, __kindof NSObject *> *)dictionary;
/*! @abstract  Calls the default initializer then passes the referenced dictionary to `CQKSerializable` updateWithData:. */
- (nullable instancetype)initIntoManagedObjectContext:(nonnull NSManagedObjectContext *)context withData:(nullable NSData *)data;
/*! @abstract  Calls the default initializer then passes the referenced dictionary to `CQKSerializable` updateWithJSON:. */
- (nullable instancetype)initIntoManagedObjectContext:(nonnull NSManagedObjectContext *)context withJSON:(nullable NSString *)json;

/*!
 @method        attributeNameForSerializedKey:
 @abstract      Translates a serialized name key/casing to attribute name key/casing.
 @param         serializedKey The key name from the dictionary being processed.
 @return        The property name with the property key casing style applied.
 @return        A nil return will skip the deserialization for this key.
 */
- (nullable NSString *)attributeNameForSerializedKey:(nullable NSString *)serializedKey;

/*!
 @abstract
 @discussion    This should be overriden in subclasses to prevent serializing reverse relationships.
                i.e. Given Person -> Address (One-to-many with reverse reference); When serializing a 'Person',
                you want the related Addresses but don't want the 'Person' referenced on the 'Address'.
 */
- (nullable NSString *)serializedKeyForAttributeName:(nullable NSString *)attributeName;

/*!
 @abstract      Allows for the specifying/overriding of the class for a given relationship.
 @discussion    By default a singularized version of the provided attributeName will be used to identify the class.
                If no class is specified, NSNull class will be returned.
 */
- (nullable Class)classOfEntityForRelationshipWithAttributeName:(nullable NSString *)attributeName;

/*!
 @abstract      Allows for the overriding of managed object initialization.
 @discussion    By default, if the class conforms to `CQKSerializable`, initIntoManagedObjectContext:withDictionary: is called.
 */
- (nullable __kindof NSManagedObject *)initializedEntityOfClass:(nullable Class)entityClass forAttributeName:(nullable NSString *)attributeName withDictionary:(nullable NSDictionary<NSString *, __kindof NSObject *> *)dictionary;

@end
