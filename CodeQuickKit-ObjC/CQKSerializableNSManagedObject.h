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

@interface CQKSerializableNSManagedObject : NSManagedObject <CQKSerializable, CQKSerializableCustomizable>

/// Initialize a new NSManagedObject into the provided NSManagedObjectContext.
/// This method assumes that an NSEntityDescription exists within the NSManagedObjectContext
/// that has the exact name of the class. i.e. If the class name is "Person", a "Person" entity must
/// exist in the model.
- (nullable instancetype)initIntoManagedObjectContext:(nonnull NSManagedObjectContext *)context;
/*! @abstract  Calls the default initializer then passes the referenced dictionary to `CQKSerializable` updateWithDictionary:. */
- (nullable instancetype)initIntoManagedObjectContext:(nonnull NSManagedObjectContext *)context withDictionary:(nullable NSDictionary<NSString *, __kindof NSObject *> *)dictionary;
/*! @abstract  Calls the default initializer then passes the referenced dictionary to `CQKSerializable` updateWithData:. */
- (nullable instancetype)initIntoManagedObjectContext:(nonnull NSManagedObjectContext *)context withData:(nullable NSData *)data;
/*! @abstract  Calls the default initializer then passes the referenced dictionary to `CQKSerializable` updateWithJSON:. */
- (nullable instancetype)initIntoManagedObjectContext:(nonnull NSManagedObjectContext *)context withJSON:(nullable NSString *)json;

@end
