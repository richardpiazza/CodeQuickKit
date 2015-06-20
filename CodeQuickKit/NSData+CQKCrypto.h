//
//  NSData+CQKCrypto.h
//  CodeQuickKit
//
//  Created by Richard Piazza on 6/20/15.
//  Copyright (c) 2015 Richard Piazza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSData (CQKCrypto)

- (NSData *)md5Hash;

@end
