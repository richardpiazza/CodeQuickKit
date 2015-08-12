/*  
 *  CodeQuickKit.h
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

#import <UIKit/UIKit.h>

//! Project version number for CodeQuickKit.
FOUNDATION_EXPORT double CodeQuickKitVersionNumber;

//! Project version string for CodeQuickKit.
FOUNDATION_EXPORT const unsigned char CodeQuickKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CodeQuickKit/PublicHeader.h>
#import <CodeQuickKit/CQKCoreDataStack.h>
#import <CodeQuickKit/CQKLogger.h>
#import <CodeQuickKit/CQKSerializable.h>
#import <CodeQuickKit/CQKSerializableNSManagedObject.h>
#import <CodeQuickKit/CQKSerializableNSObject.h>
#import <CodeQuickKit/CQKUbiquityNSFileManager.h>
#import <CodeQuickKit/CQKWebAPI.h>
#import <CodeQuickKit/NSBundle+CQKBundle.h>
#import <CodeQuickKit/NSFileManager+CQKSandbox.h>
#import <CodeQuickKit/NSNumberFormatter+CQKNumberFormatters.h>
#import <CodeQuickKit/NSData+CQKCrypto.h>
#import <CodeQuickKit/NSDate+CQKDates.h>
#import <CodeQuickKit/NSObject+CQKRuntime.h>
#import <CodeQuickKit/UIAlertController+CQKAlerts.h>
#import <CodeQuickKit/UIStoryboard+CQKStoryboards.h>
