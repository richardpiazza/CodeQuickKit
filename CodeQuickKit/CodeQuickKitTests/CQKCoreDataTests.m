/*
 *  CQKCoreDataTests.m
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
#import "CQKSerializableNSManagedObject.h"
#import "CQKCoreDataStack.h"

@class CQKCDPerson;

@interface CQKCDAddress : CQKSerializableNSManagedObject
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, weak) CQKCDPerson *person;
@end

@implementation CQKCDAddress
@dynamic street;
@dynamic city;
@dynamic person;

- (NSString *)serializedKeyForPropertyName:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"person"]) {
        return nil;
    }
    
    return [super serializedKeyForPropertyName:propertyName];
}
@end

@interface CQKCDPerson : CQKSerializableNSManagedObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSSet *addresses;
@end

@interface CQKCDPerson (CoreDataGeneratedAccessors)
- (void)addAddressesObject:(CQKCDAddress *)value;
@end

@implementation CQKCDPerson
@dynamic name;
@dynamic addresses;

- (void)setDefaults
{
    [super setDefaults];
    
    [self setName:@"Unknown"];
}

- (Class)objectClassOfCollectionTypeForPropertyName:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"addresses"]) {
        return [CQKCDAddress class];
    }
    
    return [super objectClassOfCollectionTypeForPropertyName:propertyName];
}

@end

@interface CQKCoreDataTests : XCTestCase
@property (nonatomic, strong) CQKCoreDataStack *coreDataStack;
@end

@implementation CQKCoreDataTests

- (void)setUp {
    [super setUp];
    
    NSEntityDescription *addressEntity = [[NSEntityDescription alloc] init];
    [addressEntity setName:NSStringFromClass([CQKCDAddress class])];
    [addressEntity setManagedObjectClassName:NSStringFromClass([CQKCDAddress class])];
    
    NSEntityDescription *personEntity = [[NSEntityDescription alloc] init];
    [personEntity setName:NSStringFromClass([CQKCDPerson class])];
    [personEntity setManagedObjectClassName:NSStringFromClass([CQKCDPerson class])];
    
    NSAttributeDescription *addressAttributeStreet = [[NSAttributeDescription alloc] init];
    [addressAttributeStreet setName:@"street"];
    [addressAttributeStreet setAttributeType:NSStringAttributeType];
    [addressAttributeStreet setOptional:NO];
    
    NSAttributeDescription *addressAttributeCity = [[NSAttributeDescription alloc] init];
    [addressAttributeCity setName:@"city"];
    [addressAttributeCity setAttributeType:NSStringAttributeType];
    [addressAttributeCity setOptional:NO];
    
    NSRelationshipDescription *addressRelationshipPerson = [[NSRelationshipDescription alloc] init];
    [addressRelationshipPerson setName:@"person"];
    [addressRelationshipPerson setDestinationEntity:personEntity];
    [addressRelationshipPerson setMinCount:0];
    [addressRelationshipPerson setMaxCount:1];
    [addressRelationshipPerson setDeleteRule:NSNullifyDeleteRule];
    
    NSAttributeDescription *personAttributeName = [[NSAttributeDescription alloc] init];
    [personAttributeName setName:@"name"];
    [personAttributeName setAttributeType:NSStringAttributeType];
    [personAttributeName setOptional:NO];
    
    NSRelationshipDescription *personRelationshipAddresses = [[NSRelationshipDescription alloc] init];
    [personRelationshipAddresses setName:@"addresses"];
    [personRelationshipAddresses setDestinationEntity:addressEntity];
    [personRelationshipAddresses setMinCount:0];
    [personRelationshipAddresses setDeleteRule:NSCascadeDeleteRule];
    [personRelationshipAddresses setInverseRelationship:addressRelationshipPerson];
    
    [addressRelationshipPerson setInverseRelationship:personRelationshipAddresses];
    
    [addressEntity setProperties:@[addressAttributeCity, addressAttributeStreet, addressRelationshipPerson]];
    [personEntity setProperties:@[personAttributeName, personRelationshipAddresses]];
    
    [self setCoreDataStack:[[CQKCoreDataStack alloc] initWithEntities:@[addressEntity, personEntity] delegate:nil]];
}

- (void)tearDown {
    [self.coreDataStack invalidate];
    [self setCoreDataStack:nil];
    
    [super tearDown];
}

- (void)testInitManagedObjects
{
    CQKCDPerson *person = [[CQKCDPerson alloc] initIntoManagedObjectContext:[self.coreDataStack managedObjectContext]];
    [person setName:@"Bob"];
    
    CQKCDAddress *address1 = [[CQKCDAddress alloc] initIntoManagedObjectContext:[self.coreDataStack managedObjectContext]];
    [address1 setStreet:@"123 Main Street"];
    [address1 setCity:@"Your Town"];
    
    [person addAddressesObject:address1];
    
    [[self.coreDataStack managedObjectContext] save:NULL];
    
    NSDictionary *dictionary = person.dictionary;
    NSString *json = person.json;
    
    XCTAssertNotNil(dictionary);
    XCTAssertNotNil(json);
}

- (void)testInitWithJson
{
    static NSString * const json = @"{\"name\":\"Bob\",\"addresses\":[{\"street\":\"123 Main Street\",\"city\":\"Your Town\"}]}";
    
    CQKCDPerson *person = [[CQKCDPerson alloc] initIntoManagedObjectContext:[self.coreDataStack managedObjectContext] withJSON:json];
    [[self.coreDataStack managedObjectContext] save:NULL];
    
    XCTAssertTrue([person.name isEqual:@"Bob"]);
    
    CQKCDAddress *address = [[person.addresses allObjects] firstObject];
    XCTAssertNotNil(address);
    XCTAssertTrue([address.street isEqualToString:@"123 Main Street"]);
    XCTAssertTrue([address.city isEqualToString:@"Your Town"]);
}

@end
