//
//  NSData+CQKCrypto.m
//  CodeQuickKit
//
//  Created by Richard Piazza on 6/20/15.
//  Copyright (c) 2015 Richard Piazza. All rights reserved.
//

#import "NSData+CQKCrypto.h"

@implementation NSData (CQKCrypto)

- (NSData *)md5Hash
{
    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (unsigned int)self.length, buffer);
    return [NSData dataWithBytes:buffer length:CC_MD5_DIGEST_LENGTH];
}

@end
