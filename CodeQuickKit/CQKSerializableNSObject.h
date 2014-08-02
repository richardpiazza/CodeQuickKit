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

/*!
 @abstract      Casing styles for CQKSerializableNSObject properties.
 @discussion    By default, CamelCase is used for the property style and
                TitleCase is used for the serialization style.
 */
typedef enum : NSUInteger {
    CQKSerializableNSObjectKeyStyleTitleCase = 0,
    CQKSerializableNSObjectKeyStyleCamelCase,
    CQKSerializableNSObjectKeyStyleUpperCase,
    CQKSerializableNSObjectKeyStyleLowerCase
} CQKSerializableNSObjectKeyStyle;

/*!
 @abstract      CQKSerializableNSObjectProtocol
 @discussion    Defines methods that can be overridden on CQKSerializableNSObject
                subclasses to customize the de/seriailization process. All of these methods have
                a default implementation in this class.
 */
@protocol CQKSerializableNSObjectProtocol <NSObject>
/*!
 @method        propertyNameForSerializedKey:
 @abstract      Translates a serialized name key/casing to property name key/casing.
 @param         serializedKey The key name from the dictionary being processed.
 @return        The property name with the property key casing style applied.
 @return        A nil return will skip the deserialization for this key.
 */
- (NSString *)propertyNameForSerializedKey:(NSString *)serializedKey;

/*!
 @method        serializedKeyForPropertyName:
 @abstract      Translates a property name key/casing to serialized name key/casing.
 @param         propertyName The instance property name being processed.
 @return        The key name with the serialized key casing style applied.
 @return        A nil return will skip the serialization for this key.
 */
- (NSString *)serializedKeyForPropertyName:(NSString *)propertyName;

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
- (id <NSObject>)initializedObjectForPropertyName:(NSString *)propertyName withData:(id)data;

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
- (id <NSObject>)serializedObjectForPropertyName:(NSString *)propertyName withData:(id)data;
@end

/*!
 @abstract      CQKSerializableNSObject
 @discussion    Leverages the ObjC runtime to automatically de/serialize all \@property
                objects to a dictionary/json string.
 */
@interface CQKSerializableNSObject : NSObject <NSCoding, NSCopying, CQKSerializableNSObjectProtocol>

/*!
 @method    initWithDictionary:
 @abstract  Initializes a subclass of CQKSerializableNSObject.
 @param     dictionary The dictionary representation of the object.
 @return    The initialized object.
 */
- (id <CQKSerializableNSObjectProtocol>)initWithDictionary:(NSDictionary *)dictionary;

/*!
 @method    updateWithDictionary:
 @abstract  Sets/Updates properties with new/updated values.
 @param     dictionary The dictionary representation of the object.
 */
- (void)updateWithDictionary:(NSDictionary *)dictionary;

/*!
 @method        dictionary
 @abstract      Uses the CQKSerializableNSObjectProtocol methods to create a dictionary
                representation of the object.
 @discussion    All values in the dictionary will be presented as one of four types:
                NSString, NSNumber, NSArray, NSDictionary
                Properties that are a subclass of CQKSerializableNSObject are automatically
                presented as a NSDictionary object.
 @return        A NSDictionary representation of the object.
 */
- (NSDictionary *)dictionary;

/*!
 @method    initWithData
 @abstract  Initializes a subclass of
 @param     data A NSData serialized dictionary representing the object.
 @return    The initialized object.
 */
- (id <CQKSerializableNSObjectProtocol>)initWithData:(NSData *)data;

/*!
 @method    updateWithData
 @abstract  Parses the NSData object through the NSJSONSerialization class resulting
            in a NSDictionary which will be passed to the updateWithDictionary method.
 @param     data A NSData serialized dictionary representing the object.
 */
- (void)updateWithData:(NSData *)data;

/*!
 @method        data
 @abstract      Parses the dictionary representation of this object through the
                NSJSONSerialization class.
 @return        A UTF8 encoded data object.
 */
- (NSData *)data;

/*!
 @method    initWithJSON:
 @abstract  Passes a UTF8 json string to the updateWithJSON method.
 @param     json a UTF8 encoded JSON string
 @return    The initialized object.
 */
- (id <CQKSerializableNSObjectProtocol>)initWithJSON:(NSString *)json;

/*!
 @method    updateWithJSON:
 @abstract  Creates a NSData object from a UTF8 encoded string and passes it to the
            updateWithData method.
 @param     json a UTF8 encoded JSON string
 */
- (void)updateWithJSON:(NSString *)json;

/*!
 @method    json
 @abstract  Creates a UTF8 encoded string of the NSData object.
 @return    A string representation of a JSON object.
 */
- (NSString *)json;

/*!
 @method    setPropertyKeyStyle:
 @abstract  Allows for the overriding of the objects property key casing style.
            The default is CamelCase.
 */
+ (void)setPropertyKeyStyle:(CQKSerializableNSObjectKeyStyle)keyStyle;

/*!
 @method    setSerializedKeyStyle:
 @abstract  Allows for the overriding of the objects serialized key casing style.
            The default is TitleCase.
 */
+ (void)setSerializedKeyStyle:(CQKSerializableNSObjectKeyStyle)keyStyle;

/*!
 @method        setAutoRekeyUUIDProperty:
 @abstract      Overrides the default handling of a NSUUID property with the name of *uuid.
 @discussion    Since 'id' is a reserved keyword in Objective-C the property name *uuid is 
                commonly used as the unique object identifier. By default CQKSerializableNSObjects
                with a *uuid property with de/serialized like this:
                (PropertyName) uuid = (I/i)d (SerializedKey)
 @param         rekey Allows for the disabling of the auto uuid to id keying.
 */
+ (void)setAutoRekeyUUIDProperty:(BOOL)rekey;

/*!
 @method    setLogActivity:
 @abstract  Logs failures and errors to the console. Default is NO.
 */
+ (void)setLogActivity:(BOOL)logActivity;

@end

extern NSString * const CQKSerializableNSObjectDateFormat;
extern NSString * const CQKSerializableNSObjectUUIDPropertyName;
extern NSString * const CQKSerializableNSObjectIDSerializedKey;
