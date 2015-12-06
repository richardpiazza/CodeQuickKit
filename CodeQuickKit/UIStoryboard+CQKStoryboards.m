/*
 *  UIStoryboard+CQKStoryboards.m
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

#import "UIStoryboard+CQKStoryboards.h"
#import "NSBundle+CQKBundle.h"
#import "CQKLogger.h"

@implementation UIStoryboard (CQKStoryboards)

+ (UIStoryboard *)mainStoryboard
{
    NSBundle *bundle = [NSBundle mainBundle];
    if ([bundle.infoDictionary count] == 0) {
        bundle = [NSBundle bundleForClass:[self class]];
    }
    
    @try {
        return [UIStoryboard storyboardWithName:bundle.mainStoryboard bundle:bundle];
    }
    @catch (NSException *exception) {
        [CQKLogger logError:nil withFormat:@"mainStoryboard exception: %@", exception.reason];
    }
    @finally {}
    
    return nil;
}

- (__kindof UIViewController *)instantiateViewControllerForClass:(Class)viewControllerClass
{
    [CQKLogger log:CQKLoggerLevelVerbose message:[NSString stringWithFormat:@"instantiateViewControllerForClass:%@", viewControllerClass] error:nil callingClass:[self class]];
    
    if ([viewControllerClass isSubclassOfClass:[NSNull class]]) {
        return nil;
    }
    
    NSString *identifier = NSStringFromClass(viewControllerClass);
    
    @try {
        return [self instantiateViewControllerWithIdentifier:identifier];
    }
    @catch (NSException *exception) {
        [CQKLogger logException:exception message:@"instantiateViewControllerForClass:"];
    }
    @finally {}
    
    NSBundle *bundle = [NSBundle mainBundle];
    if ([bundle.infoDictionary count] == 0) {
        bundle = [NSBundle bundleForClass:[self class]];
    }
    NSString *bundlePrefix = [NSString stringWithFormat:@"%@.", bundle.bundleDisplayName];
    
    if ([identifier hasPrefix:bundlePrefix]) {
        NSString *sansBundleIdentifier = [identifier substringFromIndex:bundlePrefix.length];
        @try {
            return [self instantiateViewControllerWithIdentifier:sansBundleIdentifier];
        }
        @catch (NSException *exception) {
            [CQKLogger logException:exception message:@"instantiateViewControllerForClass:"];
        }
        @finally {
        }
    }
    
    return nil;
}

@end

@implementation UIViewController (CQKStoryboards)

- (__kindof UIViewController *)initFromStoryboard:(UIStoryboard *)storyboard
{
    NSString *class = NSStringFromClass([self class]);
    return [self initFromStoryboard:storyboard withIdentifier:class];
}

- (__kindof UIViewController *)initFromStoryboard:(UIStoryboard *)storyboard withIdentifier:(NSString *)identifier
{
    [CQKLogger log:CQKLoggerLevelVerbose message:[NSString stringWithFormat:@"initFromStoryboard:%@ withIdentifier:%@", storyboard, identifier] error:nil callingClass:[self class]];
    
    if (storyboard == nil) {
        storyboard = [UIStoryboard mainStoryboard];
    }
    
    @try {
        id instance = [storyboard instantiateViewControllerWithIdentifier:identifier];
        [CQKLogger log:CQKLoggerLevelVerbose message:[NSString stringWithFormat:@"initialized %@ with identifier: %@", instance, identifier] error:nil callingClass:[self class]];
        return instance;
    }
    @catch (NSException *exception) {
        [CQKLogger logException:exception message:@"initFromStoryboard:"];
    }
    @finally {
    }
    
    NSBundle *bundle = [NSBundle mainBundle];
    if ([bundle.infoDictionary count] == 0) {
        bundle = [NSBundle bundleForClass:[self class]];
    }
    NSString *bundlePrefix = [NSString stringWithFormat:@"%@.", bundle.bundleDisplayName];
    
    if ([identifier hasPrefix:bundlePrefix]) {
        [CQKLogger log:CQKLoggerLevelVerbose message:@"initFromStoryboard:withIdentifier: Detected Module Prefix" error:nil callingClass:[self class]];
        NSString *sansBundleIdentifier = [identifier substringFromIndex:bundlePrefix.length];
        @try {
            id instance = [storyboard instantiateViewControllerWithIdentifier:sansBundleIdentifier];
            [CQKLogger log:CQKLoggerLevelVerbose message:[NSString stringWithFormat:@"initialized %@ with identifier: %@", instance, sansBundleIdentifier] error:nil callingClass:[self class]];
            return instance;
        }
        @catch (NSException *exception) {
            [CQKLogger logException:exception message:@"initFromStoryboard:"];
        }
        @finally {
        }
    }
    
    [CQKLogger log:CQKLoggerLevelVerbose message:@"initFromStoryboard:withIdentifier: Falling Back To Nib" error:nil callingClass:[self class]];
    
    @try {
        id instance = [self initWithNibName:identifier bundle:bundle];
        [CQKLogger log:CQKLoggerLevelVerbose message:[NSString stringWithFormat:@"initialized %@ from nib: %@", instance, identifier] error:nil callingClass:[self class]];
        return instance;
    }
    @catch (NSException *exception) {
        [CQKLogger logException:exception message:@"initFromStoryboard:"];
    }
    @finally {
    }
    
    [CQKLogger log:CQKLoggerLevelVerbose message:@"initFromStoryboard:withIdentifier: Returning NIL" error:nil callingClass:[self class]];
    return nil;
}

@end

@implementation UITableViewController (CQKStoryboards)

- (__kindof UITableViewController *)initFromStoryboard:(UIStoryboard *)storyboard
{
    NSString *class = NSStringFromClass([self class]);
    return [self initFromStoryboard:storyboard withIdentifier:class];
}

- (__kindof UITableViewController *)initFromStoryboard:(UIStoryboard *)storyboard withIdentifier:(NSString *)identifier
{
    [CQKLogger log:CQKLoggerLevelVerbose message:[NSString stringWithFormat:@"initFromStoryboard:%@ withIdentifier:%@", storyboard, identifier] error:nil callingClass:[self class]];
    
    if (storyboard == nil) {
        storyboard = [UIStoryboard mainStoryboard];
    }
    
    @try {
        id instance = [storyboard instantiateViewControllerWithIdentifier:identifier];
        [CQKLogger log:CQKLoggerLevelVerbose message:[NSString stringWithFormat:@"initialized %@ with identifier: %@", instance, identifier] error:nil callingClass:[self class]];
        return instance;
    }
    @catch (NSException *exception) {
        [CQKLogger logException:exception message:@"initFromStoryboard:"];
    }
    @finally {
    }
    
    NSBundle *bundle = [NSBundle mainBundle];
    if ([bundle.infoDictionary count] == 0) {
        bundle = [NSBundle bundleForClass:[self class]];
    }
    NSString *bundlePrefix = [NSString stringWithFormat:@"%@.", bundle.bundleDisplayName];
    
    if ([identifier hasPrefix:bundlePrefix]) {
        [CQKLogger log:CQKLoggerLevelVerbose message:@"initFromStoryboard:withIdentifier: Detected Module Prefix" error:nil callingClass:[self class]];
        NSString *sansBundleIdentifier = [identifier substringFromIndex:bundlePrefix.length];
        @try {
            id instance = [storyboard instantiateViewControllerWithIdentifier:sansBundleIdentifier];
            [CQKLogger log:CQKLoggerLevelVerbose message:[NSString stringWithFormat:@"initialized %@ with identifier: %@", instance, sansBundleIdentifier] error:nil callingClass:[self class]];
            return instance;
        }
        @catch (NSException *exception) {
            [CQKLogger logException:exception message:@"initFromStoryboard:"];
        }
        @finally {
        }
    }
    
    [CQKLogger log:CQKLoggerLevelVerbose message:@"initFromStoryboard:withIdentifier: Falling Back To Nib" error:nil callingClass:[self class]];
    
    @try {
        id instance = [self initWithNibName:identifier bundle:bundle];
        [CQKLogger log:CQKLoggerLevelVerbose message:[NSString stringWithFormat:@"initialized %@ from nib: %@", instance, identifier] error:nil callingClass:[self class]];
        return instance;
    }
    @catch (NSException *exception) {
        [CQKLogger logException:exception message:@"initFromStoryboard:"];
    }
    @finally {
    }
    
    [CQKLogger log:CQKLoggerLevelVerbose message:@"initFromStoryboard:withIdentifier: Returning NIL" error:nil callingClass:[self class]];
    return nil;
}

@end
