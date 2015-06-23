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

typedef void (^CQKAlertsDefaultCompletion)(NSString *selectedAction, BOOL wasCanceled);
typedef void (^CQKAlertsTextCompletion)(NSString *selectedAction, BOOL wasCanceled, NSString *enteredText);
typedef void (^CQKAlertsCredentialCompletion)(NSString *selectedAction, BOOL wasCanceled, NSURLCredential *enteredCredentials);

@interface UIAlertController (CQKAlerts)

+ (void)promptPresentedFromViewController:(UIViewController *)viewController withMessage:(NSString *)message action:(NSString *)action;

+ (void)alertPresentedFromViewController:(UIViewController *)viewController
                               withTitle:(NSString *)title
                                 message:(NSString *)message
                            cancelAction:(NSString *)cancelAction
                       destructiveAction:(NSString *)destructiveAction
                            otherActions:(NSArray *)otherActions
                              completion:(CQKAlertsDefaultCompletion)completion;

+ (void)textAlertPresentedFromViewController:(UIViewController *)viewController
                                   withTitle:(NSString *)title
                                     message:(NSString *)message
                                 initialText:(NSString *)initialText
                                cancelAction:(NSString *)cancelAction
                                otherActions:(NSArray *)otherActions
                                  completion:(CQKAlertsTextCompletion)completion;

+ (void)secureAlertPresentedFromViewController:(UIViewController *)viewController
                                     withTitle:(NSString *)title
                                       message:(NSString *)message
                                   initialText:(NSString *)initialText
                                  cancelAction:(NSString *)cancelAction
                                  otherActions:(NSArray *)otherActions
                                    completion:(CQKAlertsTextCompletion)completion;

+ (void)credentialAlertPresentedFromViewController:(UIViewController *)viewController
                                         withTitle:(NSString *)title
                                           message:(NSString *)message
                                initialCredentials:(NSURLCredential *)initialCredentials
                                      cancelAction:(NSString *)cancelAction
                                      otherActions:(NSArray *)otherActions
                                         compltion:(CQKAlertsCredentialCompletion)completion;

+ (void)sheetPresentedFromViewController:(UIViewController *)viewController
                          withSourceView:(UIView *)sourceView
                                   title:(NSString *)title
                                 message:(NSString *)message
                            cancelAction:(NSString *)cancelAction
                       destructiveAction:(NSString *)destructiveAction
                            otherActions:(NSArray *)otherActions
                              completion:(CQKAlertsDefaultCompletion)completion;

@end
