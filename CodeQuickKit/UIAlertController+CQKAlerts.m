/*
 *  UIAlertController+CQKAlerts.m
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

#import "UIAlertController+CQKAlerts.h"

@implementation UIAlertController (CQKAlerts)

static UIAlertController *_alertController;
static NSString *_cancelAction;
static CQKAlertsDefaultCompletion _defaultCompletion;
static CQKAlertsTextCompletion _textCompletion;
static CQKAlertsCredentialCompletion _credentialCompletion;

+ (void)dismissAlertController
{
    if (_alertController == nil) {
        return;
    }
    
    [_alertController dismissViewControllerAnimated:YES completion:nil];
    _alertController = nil;
    
    if (_defaultCompletion != nil) {
        _defaultCompletion(_cancelAction, YES);
        _defaultCompletion = nil;
    } else if (_textCompletion != nil) {
        _textCompletion(_cancelAction, YES, nil);
        _textCompletion = nil;
    } else if (_credentialCompletion != nil) {
        _credentialCompletion(_cancelAction, YES, nil);
        _credentialCompletion = nil;
    }
    
    _cancelAction = nil;
}

+ (void)alertPresentedFromViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                                 message:(NSString *)message
                            cancelAction:(NSString *)cancelAction
                       destructiveAction:(NSString *)destructiveAction
                            otherActions:(NSArray *)otherActions
                              completion:(CQKAlertsDefaultCompletion)completion
{
    [self dismissAlertController];
    
    if (viewController == nil) {
        viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    }
    
    _alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelAction != nil) {
        _cancelAction = cancelAction;
        _defaultCompletion = completion;
        
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:cancelAction style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (completion != nil) {
                completion(cancelAction, YES);
            }
        }];
        [_alertController addAction:cancelAlertAction];
    }
    
    if (destructiveAction != nil) {
        UIAlertAction *destructiveAlertAction = [UIAlertAction actionWithTitle:destructiveAction style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            if (completion != nil) {
                completion(destructiveAction, NO);
            }
        }];
        [_alertController addAction:destructiveAlertAction];
    }
    
    if (otherActions != nil) {
        for (id title in otherActions) {
            if (![[title class] isSubclassOfClass:[NSString class]]) {
                continue;
            }
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (completion != nil) {
                    completion(title, NO);
                }
            }];
            [_alertController addAction:action];
        }
    }
    
    [viewController presentViewController:_alertController animated:YES completion:nil];
}

+ (void)textAlertPresentedFromViewController:(UIViewController *)viewController
                                   withTitle:(NSString *)title
                                     message:(NSString *)message
                                 initialText:(NSString *)initialText
                                cancelAction:(NSString *)cancelAction
                                otherActions:(NSArray *)otherActions
                                  completion:(CQKAlertsTextCompletion)completion
{
    [self dismissAlertController];
    
    
}

+ (void)secureAlertPresentedFromViewController:(UIViewController *)viewController
                                     withTitle:(NSString *)title
                                       message:(NSString *)message
                                   initialText:(NSString *)initialText
                                  cancelAction:(NSString *)cancelAction
                                  otherActions:(NSArray *)otherActions
                                    completion:(CQKAlertsTextCompletion)completion
{
    [self dismissAlertController];
    
    
}

+ (void)credentialAlertPresentedFromViewController:(UIViewController *)viewController
                                         withTitle:(NSString *)title
                                           message:(NSString *)message
                                initialCredentials:(NSURLCredential *)initialCredentials
                                      cancelAction:(NSString *)cancelAction
                                      otherActions:(NSArray *)otherActions
                                         compltion:(CQKAlertsCredentialCompletion)completion
{
    [self dismissAlertController];
    
    
}

+ (void)sheetPresentedFromViewController:(UIViewController *)viewController
                          withSourceView:(UIView *)sourceView
                                   title:(NSString *)title
                                 message:(NSString *)message
                            cancelAction:(NSString *)cancelAction
                       destructiveAction:(NSString *)destructiveAction
                            otherActions:(NSArray *)otherActions
                              completion:(CQKAlertsDefaultCompletion)completion
{
    [self dismissAlertController];
    
    
}

@end
