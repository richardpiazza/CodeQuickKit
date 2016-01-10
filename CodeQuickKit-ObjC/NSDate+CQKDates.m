/*
 *  NSDate+CQKDates.m
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

#import "NSDate+CQKDates.h"

@implementation NSDate (CQKDates)

+ (NSDate *)yesturday
{
    return [[NSDate date] dateByAddingDays:-1];
}

+ (NSDate *)twoDaysAgo
{
    return [[NSDate date] dateByAddingDays:-2];
}

+ (NSDate *)lastWeek
{
    return [[NSDate date] dateByAddingDays:-7];
}

- (BOOL)isBefore:(NSDate *)date
{
    return ([[NSCalendar currentCalendar] compareDate:self toDate:date toUnitGranularity:NSCalendarUnitSecond] == NSOrderedAscending);
}

- (BOOL)isAfter:(NSDate *)date
{
    return ([[NSCalendar currentCalendar] compareDate:self toDate:date toUnitGranularity:NSCalendarUnitSecond] == NSOrderedDescending);
}

- (BOOL)isSame:(NSDate *)date
{
    return ([[NSCalendar currentCalendar] compareDate:self toDate:date toUnitGranularity:NSCalendarUnitSecond] == NSOrderedSame);
}

- (NSDate *)dateByAddingMinutes:(NSInteger)minutes
{
    return [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMinute value:minutes toDate:self options:0];
}

- (NSDate *)dateByAddingHours:(NSInteger)hours
{
    return [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitHour value:hours toDate:self options:0];
}

- (NSDate *)dateByAddingDays:(NSInteger)days
{
    return [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:days toDate:self options:0];
}

@end
