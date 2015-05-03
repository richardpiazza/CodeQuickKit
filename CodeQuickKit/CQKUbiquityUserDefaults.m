/*
 *  UIStoryboard+CQKStoryboards.h
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

#import "CQKUbiquityUserDefaults.h"

@interface CQKUbiquityUserDefaults()
@property (nonatomic, strong) NSUbiquitousKeyValueStore *keyValueStore;
@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, strong) NSString *buildNumber;
@property (nonatomic, strong) id ubiquityToken;
@end

@implementation CQKUbiquityUserDefaults

+ (CQKUbiquityUserDefaults *)ubiquityUserDefaults
{
    static CQKUbiquityUserDefaults *_ubiquityUserDefaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ubiquityUserDefaults = [[CQKUbiquityUserDefaults alloc] init];
    });
    return _ubiquityUserDefaults;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        if ([bundle.infoDictionary count] == 0) {
            bundle = [NSBundle bundleForClass:[self class]];
        }
        
        [self setUbiquityToken:[[NSFileManager defaultManager] ubiquityIdentityToken]];
        [self setBundleIdentifier:bundle.bundleIdentifier];
        [self setBuildNumber:[bundle.infoDictionary objectForKey:@"CFBundleVersion"]];
        if (self.buildNumber == nil) {
            [self setBuildNumber:@"Unknown"];
        }
        
        [self setKeyValueStore:nil];
        if ([self iCloudAvailable]) {
            [self setKeyValueStore:[NSUbiquitousKeyValueStore defaultStore]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUbiquitousKeyValueStoreItems:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:self.keyValueStore];
            [self.keyValueStore synchronize];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ubiquityIdentityDidChange:) name:NSUbiquityIdentityDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:self.keyValueStore];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUbiquityIdentityDidChangeNotification object:nil];
}

- (BOOL)iCloudAvailable
{
    return (self.ubiquityToken != nil);
}

- (void)ubiquityIdentityDidChange:(NSNotification *)notification
{
    BOOL iCloudWasAvailable = [self iCloudAvailable];
    [self setUbiquityToken:[[NSFileManager defaultManager] ubiquityIdentityToken]];
    BOOL iCloudNowAvailable = [self iCloudAvailable];
    
    if (iCloudWasAvailable && !iCloudNowAvailable) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:self.keyValueStore];
        [self setKeyValueStore:nil];
    } else if (!iCloudWasAvailable && iCloudNowAvailable) {
        [self setUbiquityToken:[NSUbiquitousKeyValueStore defaultStore]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUbiquitousKeyValueStoreItems:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:self.keyValueStore];
        [self.keyValueStore synchronize];
    }
}

- (void)updateUbiquitousKeyValueStoreItems:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    if (!reasonForChange)
        return;
    
    NSInteger reason = -1;
    reason = [reasonForChange integerValue];
    
    if ((reason == NSUbiquitousKeyValueStoreServerChange) || (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
        NSArray *changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
        for (NSString *key in changedKeys) {
            
            NSDictionary *ubiquityKVDictionary = [self ubiquityKVDictionaryForKey:key];
            if (ubiquityKVDictionary != nil) {
                
                NSDictionary *defaultsKVDictionary = [self defaultsKVDictionaryForKey:key];
                if (defaultsKVDictionary != nil) {
                    if (self.delegate != nil) {
                        if ([self.delegate ubiquityUserDefaults:self shouldReplaceExistingDictionary:defaultsKVDictionary withUbiquityDictionary:ubiquityKVDictionary]) {
                            [self defaultsSetDictionary:ubiquityKVDictionary forKey:key];
                        }
                    } else
                        [self defaultsSetDictionary:ubiquityKVDictionary forKey:key];
                } else
                    [self defaultsSetDictionary:ubiquityKVDictionary forKey:key];
            } else {
                id ubiquityObject = [self ubiquityObjectForKey:key];
                NSDictionary *defaultsKVDictionary = @{  CQKUbiquityUserDefaultsValueKey:ubiquityObject,
                                                         CQKUbiquityUserDefaultsTimestampKey:[NSDate date],
                                                         CQKUbiquityUserDefaultsBuildKey:self.buildNumber};
                [self defaultsSetDictionary:defaultsKVDictionary forKey:key];
            }
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (id)objectForKey:(NSString *)key
{
    NSString *bundleKey = [self uniqueUbiquityKeyForKey:key];
    
    id defaultsObject = [[NSUserDefaults standardUserDefaults] objectForKey:bundleKey];
    if (defaultsObject == nil) {
        return nil;
    }
    
    if (![[defaultsObject class] isSubclassOfClass:[NSDictionary class]]) {
        return defaultsObject;
    }
    
    id defaultsValue = [(NSDictionary *)defaultsObject objectForKey:CQKUbiquityUserDefaultsValueKey];
    if (defaultsValue != nil) {
        return defaultsValue;
    }
    
    return defaultsObject;
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    NSString *bundleKey = [self uniqueUbiquityKeyForKey:key];
    
    if (object == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:bundleKey];
        if (self.keyValueStore != nil) {
            [self.keyValueStore removeObjectForKey:bundleKey];
        }
        return;
    }
    
    NSDictionary *defaultsValue = @{    CQKUbiquityUserDefaultsValueKey:object,
                                        CQKUbiquityUserDefaultsTimestampKey:[NSDate date],
                                        CQKUbiquityUserDefaultsBuildKey:self.buildNumber };
    
    [self defaultsSetDictionary:defaultsValue forKey:bundleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.keyValueStore != nil)
        [self.keyValueStore setObject:defaultsValue forKey:bundleKey];
}

- (BOOL)boolForKey:(NSString *)key
{
    NSString *bundleKey = [self uniqueUbiquityKeyForKey:key];
    
    id defaultsObject = [self objectForKey:bundleKey];
    if (defaultsObject == nil) {
        defaultsObject = @NO;
        [self setBool:[defaultsObject boolValue] forKey:bundleKey];
        return [defaultsObject boolValue];
    }
    
    return [defaultsObject boolValue];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key
{
    NSString *bundleKey = [self uniqueUbiquityKeyForKey:key];
    NSNumber *defaultsValue = [NSNumber numberWithBool:value];
    [self setObject:defaultsValue forKey:bundleKey];
}

- (NSString *)uniqueUbiquityKeyForKey:(NSString *)key
{
    if ([key hasPrefix:self.bundleIdentifier]) {
        return key;
    }
    
    if ([key hasPrefix:@"."]) {
        return [NSString stringWithFormat:@"%@%@", self.bundleIdentifier, key];
    } else {
        return [NSString stringWithFormat:@"%@.%@", self.bundleIdentifier, key];
    }
}

- (NSDictionary *)defaultsKVDictionaryForKey:(NSString *)key
{
    NSString *bundleKey = [self uniqueUbiquityKeyForKey:key];
    
    id defaultsObject = [[NSUserDefaults standardUserDefaults] objectForKey:bundleKey];
    if (defaultsObject == nil) {
        return nil;
    }
    
    if (![[defaultsObject class] isSubclassOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id defaultsValue = [defaultsObject objectForKey:CQKUbiquityUserDefaultsValueKey];
    if (defaultsValue != nil) {
        return nil;
    }
    
    return defaultsObject;
}

- (NSDictionary *)ubiquityKVDictionaryForKey:(NSString *)key
{
    if (self.keyValueStore == nil) {
        return nil;
    }
    
    NSString *bundleKey = [self uniqueUbiquityKeyForKey:key];
    
    id defaultsObject = [self.keyValueStore objectForKey:bundleKey];
    if (defaultsObject == nil) {
        return nil;
    }
    
    if (![[defaultsObject class] isSubclassOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id defaultsValue = [defaultsObject objectForKey:CQKUbiquityUserDefaultsValueKey];
    if (defaultsValue != nil) {
        return nil;
    }
    
    return defaultsObject;
}

- (id)ubiquityObjectForKey:(NSString *)key
{
    if (self.keyValueStore == nil) {
        return nil;
    }
    
    NSString *bundleKey = [self uniqueUbiquityKeyForKey:key];
    
    return [self.keyValueStore objectForKey:bundleKey];
}

- (void)defaultsSetDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    if (dictionary == nil || key == nil)
        return;
    
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:key];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(ubiquityUserDefaults:didSetDictionary:forKey:)]) {
        [self.delegate ubiquityUserDefaults:self didSetDictionary:dictionary forKey:key];
    }
}

@end

NSString * const CQKUbiquityUserDefaultsValueKey = @"value";
NSString * const CQKUbiquityUserDefaultsTimestampKey = @"timestamp";
NSString * const CQKUbiquityUserDefaultsBuildKey = @"build";
