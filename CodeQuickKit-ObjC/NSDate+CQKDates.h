/*
 *  NSDate+CQKDates.h
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

#import <Foundation/Foundation.h>

@interface NSDate (CQKDates)

/*! @abstract Provides the current datetime minus 24 hours. */
+ (nullable NSDate *)yesturday;
/*! @abstract Provides the current datetime minus 48 hours. */
+ (nullable NSDate *)twoDaysAgo;
/*! @abstract Provides the current datetime minus 7 days. */
+ (nullable NSDate *)lastWeek;

/*! @abstract Determines if the instance date is before the reference date (second granularity). */
- (BOOL)isBefore:(nonnull NSDate *)date;
/*! @abstract Determines if the instance date is after the reference date (second granularity). */
- (BOOL)isAfter:(nonnull NSDate *)date;
/*! @abstract Determines if the instance date is equal to the reference date (second granularity). */
- (BOOL)isSame:(nonnull NSDate *)date;

/*! @abstract Uses NSCalendar to return the instance date mutated by the specified number of minutes. */
- (nullable NSDate *)dateByAddingMinutes:(NSInteger)minutes;
/*! @abstract Uses NSCalendar to return the instance date mutated by the specified number of hours. */
- (nullable NSDate *)dateByAddingHours:(NSInteger)hours;
/*! @abstract Uses NSCalendar to return the instance date mutated by the specified number of days. */
- (nullable NSDate *)dateByAddingDays:(NSInteger)days;

@end
