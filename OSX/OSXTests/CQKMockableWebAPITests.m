//
//  CQKMockableWebAPITests.m
//  CodeQuickKitOSX
//
//  Created by Richard Piazza on 12/10/15.
//  Copyright © 2015 Richard Piazza. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CQKMockableWebAPI.h"

@interface CQKMockableWebAPITests : XCTestCase
@property (nonatomic, strong) CQKMockableWebAPI *webAPI;
@end

@implementation CQKMockableWebAPITests

- (void)setUp {
    [super setUp];
    
    [self setWebAPI:[[CQKMockableWebAPI alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.example.com/api"] username:nil password:nil]];
    
    CQKMockableWebAPIResponse *response = [[CQKMockableWebAPIResponse alloc] init];
    [response setStatusCode:200];
    [response setResponseObject:@{@"name":@"Mock Me"}];
    [response setTimeout:2];
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/api/test"];
    
    [[self.webAPI responses] setValue:response forKey:url.absoluteString];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBasicResponse {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Basic Web Response"];
    
    [self.webAPI getPath:@"test" completion:^(int statusCode, id responseObject, NSError *error) {
        XCTAssert(statusCode == 200);
        XCTAssert([responseObject isKindOfClass:[NSDictionary class]]);
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        XCTAssert([[dictionary objectForKey:@"name"] isEqualToString:@"Mock Me"]);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Expectation Failed: %@", error);
        }
    }];
}

@end
