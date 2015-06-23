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
    
    if (_defaultCompletion != nil) {
        _defaultCompletion(_cancelAction, YES);
    } else if (_textCompletion != nil) {
        _textCompletion(_cancelAction, YES, nil);
    } else if (_credentialCompletion != nil) {
        _credentialCompletion(_cancelAction, YES, nil);
    }
    
    [self resetAlertController];
}

+ (void)resetAlertController
{
    _defaultCompletion = nil;
    _textCompletion = nil;
    _credentialCompletion = nil;
    _cancelAction = nil;
    _alertController = nil;
}

+ (void)promptPresentedFromViewController:(UIViewController *)viewController withMessage:(NSString *)message action:(NSString *)action
{
    [self dismissAlertController];
    
    _alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (action == nil) {
        action = @"OK";
    }
    
    _cancelAction = action;
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:action style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self resetAlertController];
    }];
    [_alertController addAction:cancelAlertAction];
    
    if (viewController == nil) {
        viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    }
    
    [viewController presentViewController:_alertController animated:YES completion:nil];
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
    
    _alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelAction != nil) {
        _cancelAction = cancelAction;
        _defaultCompletion = completion;
        
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:cancelAction style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (completion != nil) {
                completion(cancelAction, YES);
            }
            [self resetAlertController];
        }];
        [_alertController addAction:cancelAlertAction];
    }
    
    if (destructiveAction != nil) {
        UIAlertAction *destructiveAlertAction = [UIAlertAction actionWithTitle:destructiveAction style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            if (completion != nil) {
                completion(destructiveAction, NO);
            }
            [self resetAlertController];
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
                [self resetAlertController];
            }];
            [_alertController addAction:action];
        }
    }
    
    if (viewController == nil) {
        viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
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
    
    _alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelAction != nil) {
        _cancelAction = cancelAction;
        _textCompletion = completion;
        
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:cancelAction style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (completion != nil) {
                completion(cancelAction, YES, nil);
            }
            [self resetAlertController];
        }];
        [_alertController addAction:cancelAlertAction];
    }
    
    if (otherActions != nil) {
        for (id title in otherActions) {
            if (![[title class] isSubclassOfClass:[NSString class]]) {
                continue;
            }
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (completion != nil) {
                    UITextField *textField = [_alertController.textFields firstObject];
                    completion(title, NO, textField.text);
                }
                [self resetAlertController];
            }];
            [_alertController addAction:action];
        }
    }
    
    [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setText:initialText];
    }];
    
    if (viewController == nil) {
        viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    }
    
    [viewController presentViewController:_alertController animated:YES completion:nil];
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
    
    _alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelAction != nil) {
        _cancelAction = cancelAction;
        _textCompletion = completion;
        
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:cancelAction style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (completion != nil) {
                completion(cancelAction, YES, nil);
            }
            [self resetAlertController];
        }];
        [_alertController addAction:cancelAlertAction];
    }
    
    if (otherActions != nil) {
        for (id title in otherActions) {
            if (![[title class] isSubclassOfClass:[NSString class]]) {
                continue;
            }
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (completion != nil) {
                    UITextField *textField = [_alertController.textFields firstObject];
                    completion(title, NO, textField.text);
                }
                [self resetAlertController];
            }];
            [_alertController addAction:action];
        }
    }
    
    [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setText:initialText];
        [textField setSecureTextEntry:YES];
    }];
    
    if (viewController == nil) {
        viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    }
    
    [viewController presentViewController:_alertController animated:YES completion:nil];
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
    
    _alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelAction != nil) {
        _cancelAction = cancelAction;
        _credentialCompletion = completion;
        
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:cancelAction style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (completion != nil) {
                completion(cancelAction, YES, nil);
            }
            [self resetAlertController];
        }];
        [_alertController addAction:cancelAlertAction];
    }
    
    if (otherActions != nil) {
        for (id title in otherActions) {
            if (![[title class] isSubclassOfClass:[NSString class]]) {
                continue;
            }
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (completion != nil) {
                    UITextField *username = [_alertController.textFields firstObject];
                    UITextField *password = [_alertController.textFields lastObject];
                    NSURLCredential *credentials = [NSURLCredential credentialWithUser:username.text password:password.text persistence:NSURLCredentialPersistenceNone];
                    completion(title, NO, credentials);
                }
                [self resetAlertController];
            }];
            [_alertController addAction:action];
        }
    }
    
    [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setText:initialCredentials.user];
        [textField setPlaceholder:@"Username"];
    }];
    
    [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setText:initialCredentials.password];
        [textField setPlaceholder:@"Password"];
        [textField setSecureTextEntry:YES];
    }];
    
    if (viewController == nil) {
        viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    }
    
    [viewController presentViewController:_alertController animated:YES completion:nil];
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
    
    _alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (cancelAction != nil) {
        _cancelAction = cancelAction;
        _defaultCompletion = completion;
        
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:cancelAction style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (completion != nil) {
                completion(cancelAction, YES);
            }
            [self resetAlertController];
        }];
        
        [_alertController addAction:cancelAlertAction];
    }
    
    if (destructiveAction != nil) {
        UIAlertAction *destructiveAlertAction = [UIAlertAction actionWithTitle:destructiveAction style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            if (completion != nil) {
                completion(destructiveAction, NO);
            }
            [self resetAlertController];
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
                [self resetAlertController];
            }];
            [_alertController addAction:action];
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_alertController.popoverPresentationController setSourceView:sourceView];
    }
    
    if (viewController == nil) {
        viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    }
    
    [viewController presentViewController:_alertController animated:YES completion:nil];
}

@end
