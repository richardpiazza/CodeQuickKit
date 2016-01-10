/*
 *  NSObject+CQKRuntime.m
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

#import "NSObject+CQKRuntime.h"
#import "CQKSerializableNSObject.h"
#import "CQKLogger.h"
#import <objc/runtime.h>

@implementation NSObject (CQKRuntime)

+ (nonnull NSArray<NSString *> *)propertyNamesForClass:(nonnull Class)objectClass
{
    NSMutableArray *properties = [NSMutableArray array];
    
    if ([[objectClass superclass] isSubclassOfClass:[CQKSerializableNSObject class]]) {
        NSArray *superProperties = [NSObject propertyNamesForClass:[objectClass superclass]];
        [properties addObjectsFromArray:superProperties];
    }
    
    unsigned int propertyListCount;
    objc_property_t *runtimeProperties = class_copyPropertyList(objectClass, &propertyListCount);
    for (unsigned int i = 0; i < propertyListCount; i++) {
        objc_property_t runtimeProperty = runtimeProperties[i];
        const char *runtimeName = property_getName(runtimeProperty);
        NSString *propertyName = [NSString stringWithUTF8String:runtimeName];
        if (propertyName != nil) {
            [properties addObject:propertyName];
        }
    }
    free(runtimeProperties);
    
    [properties removeObject:@"superclass"];
    [properties removeObject:@"hash"];
    [properties removeObject:@"description"];
    [properties removeObject:@"debugDescription"];
    
    return properties;
}

+ (nonnull Class)classForPropertyName:(nonnull NSString *)propertyName ofClass:(nonnull Class)objectClass
{
    objc_property_t runtimeProperty = class_getProperty(objectClass, propertyName.UTF8String);
    if (runtimeProperty == nil) {
        NSString *message = [NSString stringWithFormat:@"Could not determine property name class: class_getProperty failed for property: %@", propertyName];
        [CQKLogger log:CQKLoggerLevelDebug message:message error:nil callingClass:self.class];
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
        } else if ([type isEqualToString:@"d"]) {
            return [NSNumber class]; //Double
        } else if ([type isEqualToString:@"f"]) {
            return [NSNumber class]; //Float
        } else if ([type isEqualToString:@"B"]) {
            return [NSNumber class]; //Boolean
        } else if ([type isEqualToString:@"@"]) {
            return [NSObject class];
        }
        
        NSString *message = [NSString stringWithFormat:@"%s[%@,%@]", __PRETTY_FUNCTION__, propertyName, propertyAttributesCollection];
        [CQKLogger log:CQKLoggerLevelVerbose message:message error:nil callingClass:[self class]];
        
        return [NSObject class];
    }
    
    NSString *propertyClass = [propertyClassAttribute substringFromIndex:1];
    NSString *class = [propertyClass substringWithRange:NSMakeRange(2, propertyClass.length - 3)];
    return NSClassFromString(class);
}

@end
