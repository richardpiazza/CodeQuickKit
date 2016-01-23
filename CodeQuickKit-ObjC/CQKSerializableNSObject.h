/*
 *  CQKSerializableNSObject.h
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

#import <Foundation/Foundation.h>
#import "CQKSerializable.h"

/*!
 @abstract      CQKSerializableNSObject
 @discussion    Leverages the ObjC runtime to automatically de/serialize all \@property
                objects to a dictionary/json string.
 */
@interface CQKSerializableNSObject : NSObject <NSCoding, NSCopying, CQKSerializable>

/*!
 @method        propertyNameForSerializedKey:
 @abstract      Translates a serialized name key/casing to property name key/casing.
 @param         serializedKey The key name from the dictionary being processed.
 @return        The property name with the property key casing style applied.
 @return        A nil return will skip the deserialization for this key.
 */
- (nullable NSString *)propertyNameForSerializedKey:(nullable NSString *)serializedKey;

/*!
 @method        serializedKeyForPropertyName:
 @abstract      Translates a property name key/casing to serialized name key/casing.
 @param         propertyName The instance property name being processed.
 @return        The key name with the serialized key casing style applied.
 @return        A nil return will skip the serialization for this key.
 */
- (nullable NSString *)serializedKeyForPropertyName:(nullable NSString *)propertyName;

/*!
 @method        initializedObjectForPropertyName:withData:
 @abstract      Overrides the default initialization behavior for a given property.
 @discussion    Many serialized object types can be nativly deserialized to their
                corresponding NSObject types. Objects that are a subclass of
                CQKSerializableNSObject will automatically be initialized.
                Every element of an NSArray will be passed to this method.
 @param         propertyName The instance property name being processed.
 @param         data The data to be used to initialize the property.
 @return        The initialized object
 */
- (nullable id <NSObject>)initializedObjectForPropertyName:(nullable NSString *)propertyName withData:(nullable id)data;

/*!
 @method        serializedObjectForPropertyname:withData:
 @abstract      Overrides the default serialization behavior for a given property.
 @discussion    Several NSObject subclasses can nativley be serialized with the
                NSJSONSerialization class. This method provieds the opportunity to
                translate non supported formats to a supported one. Object that are
                a subclass of CQKSerializableNSObject will automatically have their
                NSDictionary representation returned.
 @param         propertyName The instance property name being processed.
 @param         data The property value to be serialized.
 @return        The serialized object.
 */
- (nullable id <NSObject>)serializedObjectForPropertyName:(nullable NSString *)propertyName withData:(nullable id)data;

@end
