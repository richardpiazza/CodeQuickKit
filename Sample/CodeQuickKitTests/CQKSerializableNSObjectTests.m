/*
 *  CQKSerializableNSObjectTests.m
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
#import <CodeQuickKit/CQKSerializableNSObject.h>

@interface CQKAddress : CQKSerializableNSObject
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSNumber *zipcode;
@property (nonatomic, strong) NSString *country;
@end

@implementation CQKAddress
@end

/*!
 @abstract  Provides an example of automatic de/serialization of CQKSerializableNSObject subclass
            as well as overriding the default initialization method.
 */
@interface CQKPerson : CQKSerializableNSObject
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *dateOfBirth;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) CQKAddress *address;
@property (nonatomic, strong) NSMutableArray *favoriteURLs;
@end

@implementation CQKPerson
- (id<NSObject>)initializedObjectForPropertyName:(NSString *)propertyName withData:(id<NSObject>)data
{
    if ([propertyName isEqualToString:@"favoriteURLs"])
        return [NSURL URLWithString:(NSString *)data];
    
    return [super initializedObjectForPropertyName:propertyName withData:data];
}
@end

/*!
 @abstract      CQKSerializableNSObjectTests
 @discussion    When testing CQKSerializableNSObject classes, it is important to note
                that serialization order is not guaranteed.
 */
@interface CQKSerializableNSObjectTests : XCTestCase

@end

static NSUUID *personId;
static NSDate *personDateOfBirth;
static NSString * const personName = @"Richard";
static NSString * const personNumber = @"555-555-5555";
static NSString * const addressStreet = @"100 William Street";
static NSString * const addressCity = @"Perth";
static NSString * const addressState = @"WA";
static NSNumber *addressZipcode;
static NSString * const addressCountry = @"Australia";
static NSString * const favoriteUrlApple = @"http://www.apple.com";
static NSString * const favoriteUrlGithub = @"http://www.github.com";
static NSString * const favoriteUrlSocial = @"http://plus.google.com";
static NSString * const Serialized01 = @"{\"Name\":\"Richard\",\"DateOfBirth\":\"1982-11-05T16:00:00\",\"Phone\":\"555-555-5555\",\"Address\":{\"Country\":\"Australia\",\"Street\":\"100 William Street\",\"City\":\"Perth\",\"State\":\"WA\",\"Zipcode\":6000},\"FavoriteURLs\":[\"http://www.apple.com\",\"http://www.github.com\",\"http://plus.google.com\"],\"Id\":\"BEA9C47F-B002-4E84-91AD-582D0D19541D\"}";
static NSString * const Serialized02 = @"{\"Address\":{\"Street\":\"100 William Street\",\"Zipcode\":6000,\"City\":\"Perth\",\"State\":\"WA\",\"Country\":\"Australia\"},\"Name\":\"Richard\",\"Phone\":\"555-555-5555\",\"DateOfBirth\":\"1982-11-05T16:00:00\",\"FavoriteURLs\":[\"http://www.apple.com\",\"http://www.github.com\",\"http://plus.google.com\"],\"Id\":\"BEA9C47F-B002-4E84-91AD-582D0D19541D\"}";

@implementation CQKSerializableNSObjectTests

+ (void)setUp
{
    [[CQKSerializableNSObject configuration] setPropertyKeyStyle:CQKSerializableNSObjectKeyStyleCamelCase];
    [[CQKSerializableNSObject configuration] setSerializedKeyStyle:CQKSerializableNSObjectKeyStyleTitleCase];
    
    personId = [[NSUUID alloc] initWithUUIDString:@"BEA9C47F-B002-4E84-91AD-582D0D19541D"];
    personDateOfBirth = [[NSCalendar currentCalendar] dateWithEra:1 year:1982 month:11 day:5 hour:16 minute:0 second:0 nanosecond:0];
    addressZipcode = @(6000);
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSerialization
{
    CQKPerson *person = [[CQKPerson alloc] init];
    [person setUuid:personId];
    [person setName:personName];
    [person setDateOfBirth:personDateOfBirth];
    [person setPhone:personNumber];
    [person setAddress:[[CQKAddress alloc] init]];
    [person.address setStreet:addressStreet];
    [person.address setCity:addressCity];
    [person.address setState:addressState];
    [person.address setZipcode:addressZipcode];
    [person.address setCountry:addressCountry];
    [person setFavoriteURLs:[NSMutableArray array]];
    [person.favoriteURLs addObject:[NSURL URLWithString:favoriteUrlApple]];
    [person.favoriteURLs addObject:[NSURL URLWithString:favoriteUrlGithub]];
    [person.favoriteURLs addObject:[NSURL URLWithString:favoriteUrlSocial]];
    
    NSString *json = person.json;
    BOOL s01 = [json isEqualToString:Serialized01];
    BOOL s02 = [json isEqualToString:Serialized02];
    XCTAssertTrue(s01 || s02);
}

- (void)testDeserialization
{
    CQKPerson *person = [[CQKPerson alloc] initWithJSON:Serialized01];
    XCTAssertTrue([[person.uuid UUIDString] isEqualToString:personId.UUIDString]);
    XCTAssertTrue([person.name isEqualToString:personName]);
    XCTAssertTrue([person.dateOfBirth isEqualToDate:personDateOfBirth]);
    XCTAssertTrue([person.phone isEqualToString:personNumber]);
    XCTAssertTrue([[person.address street] isEqualToString:addressStreet]);
    XCTAssertTrue([[person.address city] isEqualToString:addressCity]);
    XCTAssertTrue([[person.address state] isEqualToString:addressState]);
    XCTAssertTrue([[person.address zipcode] isEqualToNumber:addressZipcode]);
    XCTAssertTrue([[person.address country] isEqualToString:addressCountry]);
    [person.favoriteURLs enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        BOOL s01 = [[url absoluteString] isEqual:favoriteUrlApple];
        BOOL s02 = [[url absoluteString] isEqual:favoriteUrlGithub];
        BOOL s03 = [[url absoluteString] isEqualToString:favoriteUrlSocial];
        XCTAssertTrue(s01 || s02 || s03);
    }];
}

@end
