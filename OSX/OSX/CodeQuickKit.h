//
//  OSX.h
//  OSX
//
//  Created by Richard Piazza on 10/30/15.
//  Copyright © 2015 Richard Piazza. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for OSX.
FOUNDATION_EXPORT double OSXVersionNumber;

//! Project version string for OSX.
FOUNDATION_EXPORT const unsigned char OSXVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <OSX/PublicHeader.h>
#import <CodeQuickKit/CQKCoreDataStack.h>
#import <CodeQuickKit/CQKLogger.h>
#import <CodeQuickKit/CQKMockableWebAPI.h>
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
