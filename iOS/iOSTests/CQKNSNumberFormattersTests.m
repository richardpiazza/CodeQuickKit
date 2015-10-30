/*
 *  CQKNSNumberFormattersTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSNumberFormatter+CQKNumberFormatters.h"

@interface CQKNSNumberFormattersTests : XCTestCase

@end

@implementation CQKNSNumberFormattersTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIntegerFormatter
{
    NSNumber *integer = [NSNumberFormatter integerFromString:@"25.5"];
    XCTAssertTrue([integer isEqualToNumber:@25.5]);
    NSString *string = [NSNumberFormatter integerStringFromNumber:integer];
    XCTAssertTrue([string isEqualToString:@"26"]);
}

- (void)testSingleDecimalFormatter
{
    NSNumber *singleDecimal = [NSNumberFormatter singleDecimalFromString:@"147.3627"];
    XCTAssertTrue([singleDecimal isEqualToNumber:@(147.3627)]);
    NSString *string = [NSNumberFormatter singleDecimalStringFromNumber:singleDecimal];
    XCTAssertTrue([string isEqualToString:@"147.4"]);
}

- (void)testDecimalFormatter
{
    NSNumber *decimal = [NSNumberFormatter decimalFromString:@"999"];
    XCTAssertTrue([decimal isEqualToNumber:@(999)]);
    NSString *string = [NSNumberFormatter decimalStringFromNumber:decimal];
    XCTAssertTrue([string isEqualToString:@"999"]);
}

- (void)testCurrencyFormatter
{
    NSString *currencySymbol = [[NSNumberFormatter currencyFormatter] currencySymbol];
    NSString *testCurrency = [NSString stringWithFormat:@"%@84.55", currencySymbol];
    
    NSNumber *currency = [NSNumberFormatter currencyFromString:testCurrency];
    XCTAssertTrue([currency isEqualToNumber:@(84.55)]);
    NSString *string = [NSNumberFormatter currencyStringFromNumber:currency];
    XCTAssertTrue([string isEqualToString:testCurrency]);
}

- (void)testPercentFormatter
{
    NSString *percentSymbol = [[NSNumberFormatter percentFormatter] percentSymbol];
    NSString *testPercent = [NSString stringWithFormat:@"69.75%@", percentSymbol];
    
    NSNumber *percent = [NSNumberFormatter percentFromString:testPercent];
    XCTAssertTrue([percent isEqualToNumber:@(.6975)]);
    NSString *string = [NSNumberFormatter percentStringFromNumber:percent];
    XCTAssertTrue([string isEqualToString:testPercent]);
}

@end
