/*
 *  NSObject+CQKRuntime.h
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

@interface NSObject (CQKRuntime)

/*!
 @method    propertyNamesForClass:
 @abstract  Retrieves all '\@property' objects of a class.
 @param     objectClass The Class to retrieve properties.
 @return    string List of property names.
 */
+ (nonnull NSArray<NSString *> *)propertyNamesForClass:(nonnull Class)objectClass;

/*!
 @method    classForPropertyName:ofClass:
 @abstract  Retrieved the Class for a specified propertyName of a specific class.
 @param     propertyName An '\@property' on this class.
 @param     objectClass The Class to inspect for the propertyName.
 @return    Class for a given the given property with name; Defaults to NSNull.
 */
+ (nonnull Class)classForPropertyName:(nonnull NSString *)propertyName ofClass:(nonnull Class)objectClass;

/// Returns the last component from NSStringFromClass()
+ (nonnull NSString *)nameForClass:(nonnull Class)objectClass;

/// Returns the last component from NSStringFromClass()
- (nonnull NSString *)classNameWithoutModule;

@end
