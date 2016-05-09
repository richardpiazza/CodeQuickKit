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
+ (nonnull NSNumberFormatter *)integerFormatter;
+ (nullable NSNumber *)integerFromString:(nullable NSString *)string;
+ (nullable NSString *)integerStringFromNumber:(nullable NSNumber *)number;

/*!
 @abstract      An NSNumberFormatter for whole integers.
 @discussion    Uses the NSNumberFormatterDecimalStyle with
                MaximumFractionDigits set to 1 (one).
 */
+ (nonnull NSNumberFormatter *)singleDecimalFormatter;
+ (nullable NSNumber *)singleDecimalFromString:(nullable NSString *)string;
+ (nullable NSString *)singleDecimalStringFromNumber:(nullable NSNumber *)number;

/*!
 @abstract      An NSNumberFormatter for whole integers.
 @discussion    Uses the NSNumberFormatterDecimalStyle with
                MaximumFractionDigits set to 2 (two).
 */
+ (nonnull NSNumberFormatter *)decimalFormatter;
+ (nullable NSNumber *)decimalFromString:(nullable NSString *)string;
+ (nullable NSString *)decimalStringFromNumber:(nullable NSNumber *)number;

/*!
 @abstract      An NSNumberFormatter for whole integers.
 @discussion    Uses the NSNumberFormatterCurrencyStyle.
 */
+ (nonnull NSNumberFormatter *)currencyFormatter;
+ (nullable NSNumber *)currencyFromString:(nullable NSString *)string;
+ (nullable NSString *)currencyStringFromNumber:(nullable NSNumber *)number;

/*!
 @abstract      An NSNumberFormatter for whole integers.
 @discussion    Uses the NSNumberFormatterPercentStyle with
                MinimumFractionDigits set to 1 (one) and
                MaximumFractionDigits set to 3 (three).
 */
+ (nonnull NSNumberFormatter *)percentFormatter;
+ (nullable NSNumber *)percentFromString:(nullable NSString *)string;
+ (nullable NSString *)percentStringFromNumber:(nullable NSNumber *)number;

@end
