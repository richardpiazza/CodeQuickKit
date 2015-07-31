/*
 *  CQKNSDateCQKDatesTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSDate+CQKDates.h"

@interface CQKNSDateCQKDatesTests : XCTestCase
@end

@implementation CQKNSDateCQKDatesTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testYesturday {
    NSDate *now = [NSDate date];
    NSDate *yesturday = [NSDate yesturday];
    XCTAssertNotNil(yesturday);
    NSDate *today = [yesturday dateByAddingHours:24];
    XCTAssertNotNil(today);
    NSComparisonResult equal = [[NSCalendar currentCalendar] compareDate:now toDate:today toUnitGranularity:NSCalendarUnitSecond];
    XCTAssertTrue(equal == NSOrderedSame);
    XCTAssertFalse([today isBefore:yesturday]);
}

- (void)testTwoDaysAgo {
    NSDate *now = [NSDate date];
    NSDate *twoDaysAgo = [NSDate twoDaysAgo];
    XCTAssertNotNil(twoDaysAgo);
    NSDate *today = [twoDaysAgo dateByAddingDays:2];
    XCTAssertNotNil(today);
    XCTAssertTrue([today isSame:now]);
    XCTAssertFalse([twoDaysAgo isAfter:today]);
}

- (void)testLastWeek {
    NSDate *now = [NSDate date];
    NSDate *lastWeek = [NSDate lastWeek];
    XCTAssertNotNil(lastWeek);
    NSDate *today = [lastWeek dateByAddingDays:7];
    XCTAssertNotNil(today);
    XCTAssertTrue([today isSame:now]);
}

@end
