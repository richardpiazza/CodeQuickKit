/*
 *  NSNumberFormatter+CQKNumberFormatters.h
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

#import <Foundation/Foundation.h>

/*!
 @abstract      NSNumberFormatter (CQKNumberFormatters)
 @discussion    Provides a class level reference to several commonly used
                NSNumberFormatters.
 */
@interface NSNumberFormatter (CQKNumberFormatters)

/*!
 @abstract      An NSNumberFormatter for whole integers.
 @discussion    Uses the NSNumberFormatterDecimalStyle with 
                MaximumFractionDigits set to 0 (zero).
 */
+ (NSNumberFormatter *)integerFormatter;
+ (NSNumber *)integerFromString:(NSString *)string;
+ (NSString *)integerStringFromNumber:(NSNumber *)number;

/*!
 @abstract      An NSNumberFormatter for whole integers.
 @discussion    Uses the NSNumberFormatterDecimalStyle with
                MaximumFractionDigits set to 1 (one).
 */
+ (NSNumberFormatter *)singleDecimalFormatter;
+ (NSNumber *)singleDecimalFromString:(NSString *)string;
+ (NSString *)singleDecimalStringFromNumber:(NSNumber *)number;

/*!
 @abstract      An NSNumberFormatter for whole integers.
 @discussion    Uses the NSNumberFormatterDecimalStyle with
                MaximumFractionDigits set to 2 (two).
 */
+ (NSNumberFormatter *)decimalFormatter;
+ (NSNumber *)decimalFromString:(NSString *)string;
+ (NSString *)decimalStringFromNumber:(NSNumber *)number;

/*!
 @abstract      An NSNumberFormatter for whole integers.
 @discussion    Uses the NSNumberFormatterCurrencyStyle.
 */
+ (NSNumberFormatter *)currencyFormatter;
+ (NSNumber *)currencyFromString:(NSString *)string;
+ (NSString *)currencyStringFromNumber:(NSNumber *)number;

/*!
 @abstract      An NSNumberFormatter for whole integers.
 @discussion    Uses the NSNumberFormatterPercentStyle with
                MinimumFractionDigits set to 1 (one) and
                MaximumFractionDigits set to 3 (three).
 */
+ (NSNumberFormatter *)percentFormatter;
+ (NSNumber *)percentFromString:(NSString *)string;
+ (NSString *)percentStringFromNumber:(NSNumber *)number;

@end
