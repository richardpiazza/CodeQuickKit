//
//  NSObjectTests.m
//  CodeQuickKitOSX
//
//  Created by Richard Piazza on 2/9/16.
//  Copyright © 2016 Richard Piazza. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+CQKRuntime.h"

@interface NSObjectTests : XCTestCase

@end

@implementation NSObjectTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSString *className = [self className];
    NSString *classNameWithoutModule = [self classNameWithoutModule];
    XCTAssertTrue([classNameWithoutModule isEqualToString:@"NSObjectTests"]);
}

@end
