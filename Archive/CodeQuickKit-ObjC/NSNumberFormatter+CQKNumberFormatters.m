/*
 *  NSNumberFormatter+CQKNumberFormatters.m
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

#import "NSNumberFormatter+CQKNumberFormatters.h"

@implementation NSNumberFormatter (CQKNumberFormatters)

+ (NSNumberFormatter *)integerFormatter
{
    static NSNumberFormatter *_integerFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _integerFormatter = [[NSNumberFormatter alloc] init];
        [_integerFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_integerFormatter setMaximumFractionDigits:0];
    });
    return _integerFormatter;
}

+ (NSNumber *)integerFromString:(NSString *)string
{
    return [[NSNumberFormatter integerFormatter] numberFromString:string];
}

+ (NSString *)integerStringFromNumber:(NSNumber *)number
{
    return [[NSNumberFormatter integerFormatter] stringFromNumber:number];
}

+ (NSNumberFormatter *)singleDecimalFormatter
{
    static NSNumberFormatter *_singleDecimalFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleDecimalFormatter = [[NSNumberFormatter alloc] init];
        [_singleDecimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_singleDecimalFormatter setMaximumFractionDigits:1];
    });
    return _singleDecimalFormatter;
}

+ (NSNumber *)singleDecimalFromString:(NSString *)string
{
    return [[NSNumberFormatter singleDecimalFormatter] numberFromString:string];
}

+ (NSString *)singleDecimalStringFromNumber:(NSNumber *)number
{
    return [[NSNumberFormatter singleDecimalFormatter] stringFromNumber:number];
}

+ (NSNumberFormatter *)decimalFormatter
{
    static NSNumberFormatter *_decimalFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _decimalFormatter = [[NSNumberFormatter alloc] init];
        [_decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_decimalFormatter setMaximumFractionDigits:2];
    });
    return _decimalFormatter;
}

+ (NSNumber *)decimalFromString:(NSString *)string
{
    return [[NSNumberFormatter decimalFormatter] numberFromString:string];
}

+ (NSString *)decimalStringFromNumber:(NSNumber *)number
{
    return [[NSNumberFormatter decimalFormatter] stringFromNumber:number];
}

+ (NSNumberFormatter *)currencyFormatter
{
    static NSNumberFormatter *_currencyFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currencyFormatter = [[NSNumberFormatter alloc] init];
        [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_currencyFormatter setLocale:[NSLocale currentLocale]];
    });
    return _currencyFormatter;
}

+ (NSNumber *)currencyFromString:(NSString *)string
{
    if (![string hasPrefix:[[NSNumberFormatter currencyFormatter] currencySymbol]]) {
        string = [NSString stringWithFormat:@"%@%@", [[NSNumberFormatter currencyFormatter] currencySymbol], string];
    }
    
    return [[NSNumberFormatter currencyFormatter] numberFromString:string];
}

+ (NSString *)currencyStringFromNumber:(NSNumber *)number
{
    return [[NSNumberFormatter currencyFormatter] stringFromNumber:number];
}

+ (NSNumberFormatter *)percentFormatter
{
    static NSNumberFormatter *_percentFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _percentFormatter = [[NSNumberFormatter alloc] init];
        [_percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        [_percentFormatter setMinimumFractionDigits:1];
        [_percentFormatter setMaximumFractionDigits:3];
    });
    return _percentFormatter;
}

+ (NSNumber *)percentFromString:(NSString *)string
{
    if (![string hasSuffix:[[NSNumberFormatter percentFormatter] percentSymbol]]) {
        string = [NSString stringWithFormat:@"%@%@", string, [[NSNumberFormatter percentFormatter] percentSymbol]];
    }
    
    return [[NSNumberFormatter percentFormatter] numberFromString:string];
}

+ (NSString *)percentStringFromNumber:(NSNumber *)number
{
    return [[NSNumberFormatter percentFormatter] stringFromNumber:number];
}

@end
