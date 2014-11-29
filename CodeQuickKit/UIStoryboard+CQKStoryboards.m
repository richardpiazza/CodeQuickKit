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

@implementation UIStoryboard (CQKStoryboards)

+ (UIStoryboard *)mainStoryboard
{
    NSBundle *bundle = [NSBundle mainBundle];
    if ([bundle.infoDictionary count] == 0)
        bundle = [NSBundle bundleForClass:[self class]];
    
    UIStoryboard *main;
    @try {
        main = [UIStoryboard storyboardWithName:@"Main" bundle:bundle];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        return nil;
    }
    @finally {
    }
    
    return main;
}

@end

@implementation UIViewController (CQKStoryboards)

- (id)initFromStoryboard:(UIStoryboard *)storyboard
{
    NSString *class = NSStringFromClass([self class]);
    return [self initFromStoryboard:storyboard withIdentifier:class];
}

- (id)initFromStoryboard:(UIStoryboard *)storyboard withIdentifier:(NSString *)identifier
{
    NSBundle *bundle = [NSBundle mainBundle];
    if ([bundle.infoDictionary count] == 0)
        bundle = [NSBundle bundleForClass:[self class]];
    
    id instance;
    
    if (storyboard == nil) {
        
        @try {
            instance = [self initWithNibName:identifier bundle:bundle];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
            return nil;
        }
        @finally {
        }
        
        return instance;
    }
    
    @try {
        instance = [storyboard instantiateViewControllerWithIdentifier:identifier];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        return nil;
    }
    @finally {
    }
    
    return instance;
}

@end

@implementation UITableViewController (CQKStoryboards)

- (id)initFromStoryboard:(UIStoryboard *)storyboard
{
    NSString *class = NSStringFromClass([self class]);
    return [self initFromStoryboard:storyboard withIdentifier:class];
}

- (id)initFromStoryboard:(UIStoryboard *)storyboard withIdentifier:(NSString *)identifier
{
    NSBundle *bundle = [NSBundle mainBundle];
    if ([bundle.infoDictionary count] == 0)
        bundle = [NSBundle bundleForClass:[self class]];
    
    id instance;
    
    if (storyboard == nil) {
        
        @try {
            instance = [self initWithNibName:identifier bundle:bundle];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
            return nil;
        }
        @finally {
        }
        
        return instance;
    }
    
    @try {
        instance = [storyboard instantiateViewControllerWithIdentifier:identifier];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        return nil;
    }
    @finally {
    }
    
    return instance;
}

@end
