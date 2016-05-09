/*
 *  UIAlertController+CQKAlerts.h
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

#import <UIKit/UIKit.h>

typedef void (^CQKAlertsDefaultCompletion)(NSString * _Nonnull selectedAction, BOOL wasCanceled);
typedef void (^CQKAlertsTextCompletion)(NSString * _Nonnull selectedAction, BOOL wasCanceled, NSString * _Nullable enteredText);
typedef void (^CQKAlertsCredentialCompletion)(NSString * _Nonnull selectedAction, BOOL wasCanceled, NSURLCredential * _Nullable enteredCredentials);

@interface UIAlertController (CQKAlerts)

/// A basic message and single button `.Default` alert
+ (void)promptPresentedFromViewController:(nullable __kindof UIViewController *)viewController
                              withMessage:(nullable NSString *)message
                                   action:(nullable NSString *)action;

/// A configurable `.Default` alert
+ (void)alertPresentedFromViewController:(nullable __kindof UIViewController *)viewController
                               withTitle:(nullable NSString *)title
                                 message:(nullable NSString *)message
                            cancelAction:(nullable NSString *)cancelAction
                       destructiveAction:(nullable NSString *)destructiveAction
                            otherActions:(nullable NSArray<NSString *> *)otherActions
                              completion:(nullable CQKAlertsDefaultCompletion)completion;

/// A configurable `.Default` style alert with a single `UITextField`
+ (void)textAlertPresentedFromViewController:(nullable __kindof UIViewController *)viewController
                                   withTitle:(nullable NSString *)title
                                     message:(nullable NSString *)message
                                 initialText:(nullable NSString *)initialText
                                cancelAction:(nullable NSString *)cancelAction
                                otherActions:(nullable NSArray<NSString *> *)otherActions
                                  completion:(nullable CQKAlertsTextCompletion)completion;

/// A configurable `.Default` style alert with a single secure `UITextField`
+ (void)secureAlertPresentedFromViewController:(nullable __kindof UIViewController *)viewController
                                     withTitle:(nullable NSString *)title
                                       message:(nullable NSString *)message
                                   initialText:(nullable NSString *)initialText
                                  cancelAction:(nullable NSString *)cancelAction
                                  otherActions:(nullable NSArray<NSString *> *)otherActions
                                    completion:(nullable CQKAlertsTextCompletion)completion;

/// A configurable `.Default` style alert with two `UITextField`s, the second of which is secure
+ (void)credentialAlertPresentedFromViewController:(nullable __kindof UIViewController *)viewController
                                         withTitle:(nullable NSString *)title
                                           message:(nullable NSString *)message
                                initialCredentials:(nullable NSURLCredential *)initialCredentials
                                      cancelAction:(nullable NSString *)cancelAction
                                      otherActions:(nullable NSArray<NSString *> *)otherActions
                                         compltion:(nullable CQKAlertsCredentialCompletion)completion;

/// A configurable `.ActionSheet` style alert presented from the `viewController` or `sourceView` on Regular horizontal size classes
+ (void)sheetPresentedFromViewController:(nullable __kindof UIViewController *)viewController
                       withBarButtonItem:(nullable __kindof UIBarButtonItem *)barButtonItem
                            orSourceView:(nullable __kindof UIView *)sourceView
                                   title:(nullable NSString *)title
                                 message:(nullable NSString *)message
                            cancelAction:(nullable NSString *)cancelAction
                       destructiveAction:(nullable NSString *)destructiveAction
                            otherActions:(nullable NSArray<NSString *> *)otherActions
                              completion:(nullable CQKAlertsDefaultCompletion)completion;

@end
