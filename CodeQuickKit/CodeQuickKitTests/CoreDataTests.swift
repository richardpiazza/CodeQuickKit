import XCTest
import CoreData
@testable import CodeQuickKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Address: SerializableManagedObject {
    @NSManaged var street: String?
    @NSManaged var city: String?
    @NSManaged var person: Person?
    
    override func serializedKey(forPropertyName propertyName: String) -> String? {
        if propertyName == "person" {
            return nil
        }
        
        return super.serializedKey(forPropertyName: propertyName)
    }
}

class Person: SerializableManagedObject {
    @NSManaged var name: String?
    @NSManaged var addresses: NSSet?
    
    override func setDefaults() {
        super.setDefaults()
        name = "Billy Bob"
    }
    
    override func objectClassOfCollectionType(forPropertyname propertyName: String) -> AnyClass? {
        if propertyName == "addresses" {
            return Address.self
        }
        
        return super.objectClassOfCollectionType(forPropertyname: propertyName)
    }
}

class CoreDataTests: XCTestCase {
    static let modelJSON = "{\"addresses\":[{\"city\":\"Your Town\",\"street\":\"123 Main Street\"}],\"name\":\"Bob\"}"
    static let modelJSON2 = "{\"addresses\":[{\"street\":\"123 Main Street\",\"city\":\"Your Town\"}],\"name\":\"Bob\"}"
    static let modelJSON3 = "{\"name\":\"Bob\",\"addresses\":[{\"street\":\"123 Main Street\",\"city\":\"Your Town\"}]}"
    
    var repository: NSPersistentContainer?
    
    override func setUp() {
        super.setUp()
        
        let addressEntity = NSEntityDescription()
        addressEntity.name = "Address"
        addressEntity.managedObjectClassName = "CodeQuickKitTests.Address"
        
        let personEntity = NSEntityDescription()
        personEntity.name = "Person"
        personEntity.managedObjectClassName = "CodeQuickKitTests.Person"
        
        let streetAttribute = NSAttributeDescription()
        streetAttribute.name = "street"
        streetAttribute.attributeType = .stringAttributeType
        streetAttribute.isOptional = false
        
        let cityAttribute = NSAttributeDescription()
        cityAttribute.name = "city"
        cityAttribute.attributeType = .stringAttributeType
        cityAttribute.isOptional = false
        
        let addressPerson = NSRelationshipDescription()
        addressPerson.name = "person"
        addressPerson.destinationEntity = personEntity
        addressPerson.minCount = 0
        addressPerson.maxCount = 1
        addressPerson.deleteRule = .nullifyDeleteRule
        
        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = false
        
        let personAddress = NSRelationshipDescription()
        personAddress.name = "addresses"
        personAddress.destinationEntity = addressEntity
        personAddress.minCount = 0
        personAddress.deleteRule = .cascadeDeleteRule
        personAddress.inverseRelationship = addressPerson
        addressPerson.inverseRelationship = personAddress
        
        addressEntity.properties = [cityAttribute, streetAttribute, addressPerson]
        personEntity.properties = [nameAttribute, personAddress]
        
        let model = NSManagedObjectModel()
        model.entities = [addressEntity, personEntity]
        
        repository = NSPersistentContainer(name: "Test", managedObjectModel: model)
        
        guard let coreData = repository else {
            XCTFail("Repository Not Initialized")
            return
        }
        
        let expectation = self.expectation(description: "Load Expectation")
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        
        coreData.persistentStoreDescriptions = [description]
        coreData.loadPersistentStores { (persistentDescription, error) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            if let e = error {
                print(e)
                XCTFail()
            }
        }
    }
    
    override func tearDown() {
        repository = nil
        
        super.tearDown()
    }
    
    func testInitManagedObjects() {
        guard let moc = repository?.viewContext else {
            XCTFail("MOC nil")
            return
        }
        
        guard let person = Person(managedObjectContext: moc) else {
            XCTFail("Failed to create 'Person'")
            return
        }
        
        person.name = "Bob"
        
        guard let address = Address(managedObjectContext: moc) else {
            XCTFail("Failed to create 'Address'")
            return
        }
        
        address.street = "123 Main Street"
        address.city = "Your Town"
        address.person = person
        
        do {
            try moc.save()
        } catch {
            print(error)
            XCTFail()
            return
        }
        
        guard let json = person.json else {
            XCTFail("Invalid JSON")
            return
        }
        
        XCTAssertTrue(json == CoreDataTests.modelJSON || json == CoreDataTests.modelJSON2 || json == CoreDataTests.modelJSON3)
    }
    
    func testInitWithJSON() {
        guard let moc = repository?.viewContext else {
            XCTFail("MOC nil")
            return
        }
        
        guard let person = Person(managedObjectContext: moc, withJSON: CoreDataTests.modelJSON) else {
            XCTFail("person is nil")
            return
        }
        
        do {
            try moc.save()
        } catch {
            print(error)
            XCTFail()
            return
        }
        
        XCTAssertTrue(person.name == "Bob")
        
        guard person.addresses?.count > 0 else {
            XCTFail("Address count is 0")
            return
        }
        
        guard let address = person.addresses!.allObjects[0] as? Address else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(address.street == "123 Main Street")
        XCTAssertTrue(address.city == "Your Town")
    }
    
    func testSecondaryContextChanges() {
        guard let moc = repository?.viewContext else {
            XCTFail()
            return
        }
        
        guard let person = Person(managedObjectContext: moc) else {
            XCTFail()
            return
        }
        
        moc.mergeChanges(performingBlock: { (privateContext) in
            if let guy = privateContext.object(with: person.objectID) as? Person {
                guy.name = "Hector"
            }
            
            }, withCompletion: { (error) in
                XCTAssertNil(error)
        })
        
        XCTAssertTrue(person.name == "Hector")
        
        moc.mergeChanges(performingBlock: { (privateContext) in
            if let guy = privateContext.object(with: person.objectID) as? Person {
                privateContext.delete(guy)
            }
            }, withCompletion: { (error) in
                XCTAssertNil(error)
        })
    }
}
