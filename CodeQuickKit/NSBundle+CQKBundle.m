/*
 *  NSBundle+CQKBundle.m
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

#import "NSBundle+CQKBundle.h"
#import "CQKLogger.h"

@implementation NSBundle (CQKBundle)

- (NSString *)bundleName
{
    return [self objectForInfoDictionaryKey:CQKBundleNameBundleKey];
}

- (NSString *)executableName
{
    return [self objectForInfoDictionaryKey:CQKExecutableNameBundleKey];
}

- (NSString *)appVersion
{
    return [self objectForInfoDictionaryKey:CQKAppVersionBundleKey];
}

- (NSString *)buildNumber
{
    return [self objectForInfoDictionaryKey:CQKBuildNumberBundleKey];
}

- (NSString *)bundleDescription
{
    return [NSString stringWithFormat:@"Bundle Description: %@", self.bundleDescriptionDictionary];
}

- (NSDictionary *)bundleDescriptionDictionary
{
    return @{CQKBundleNameBundleKey: (self.bundleName != nil) ? self.bundleName : @"",
             CQKExecutableNameBundleKey: (self.executableName != nil) ? self.executableName : @"",
             CQKBundleIdentifierBundleKey: (self.bundleIdentifier != nil) ? self.bundleIdentifier : @"",
             CQKAppVersionBundleKey: (self.appVersion != nil) ? self.appVersion : @"",
             CQKBuildNumberBundleKey: (self.buildNumber != nil) ? self.buildNumber : @""};
}

- (NSData *)bundleDescriptionData
{
    NSDictionary *dictionary = [self bundleDescriptionDictionary];
    @try {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL];
        return data;
    }
    @catch (NSException *exception) {
        [CQKLogger logException:exception message:@"Failed to serialize bundle description dictionary."];
        return nil;
    }
    @finally {
    }
}

@end

NSString * const CQKBundleNameBundleKey = @"CFBundleName";
NSString * const CQKExecutableNameBundleKey = @"CFBundleExecutable";
NSString * const CQKAppVersionBundleKey = @"CFBundleShortVersionString";
NSString * const CQKBuildNumberBundleKey = @"CFBundleVersion";
NSString * const CQKBundleIdentifierBundleKey = @"CFBundleIdentifier";
