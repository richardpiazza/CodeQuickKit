/*
 *  NSDateFormatter+CQKDateFormatter.m
 *
 *  Copyright (c) 2016 Richard Piazza
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

#import "NSDateFormatter+CQKDateFormatter.h"

@implementation NSDateFormatter (CQKDateFormatter)

+ (NSDateFormatter *)rfc1123DateFormatter
{
    static NSDateFormatter *_rfc1123DateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _rfc1123DateFormatter = [[NSDateFormatter alloc] init];
        [_rfc1123DateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"];
        [_rfc1123DateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [_rfc1123DateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    });
    
    return _rfc1123DateFormatter;
}

@end
