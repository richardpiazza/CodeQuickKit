import XCTest
@testable import CodeQuickKit

class Channel: SerializableObject {
    var name: String?
    var likes: NSNumber?
    var media: [Media]?
    
    override func objectClassOfCollectionType(forPropertyname propertyName: String) -> AnyClass? {
        if propertyName == "media" {
            return Media.self
        }
        
        return super.objectClassOfCollectionType(forPropertyname: propertyName)
    }
}

class Media: SerializableObject {
    var id: UUID?
    var name: String?
    var url: URL?
    var date: Date?
}

class SerializableObjectTests: XCTestCase {
    static let uuid1 = UUID(uuidString: "BEA9C47F-B002-4E84-91AD-582D0D19541D")!
    static let uuid2 = UUID(uuidString: "5C52425E-E45D-11E5-9730-9A79F06E9478")!
    static var date1: Date {
        var dateComponents = DateComponents()
        (dateComponents as NSDateComponents).calendar = Calendar.current
        (dateComponents as NSDateComponents).timeZone = TimeZone(identifier: "GMT")!
        dateComponents.era = 1
        dateComponents.year = 1982
        dateComponents.month = 11
        dateComponents.day = 5
        dateComponents.hour = 8
        dateComponents.minute = 0
        dateComponents.second = 0
        return (dateComponents as NSDateComponents).date!
    }
    static var date2: Date {
        var dateComponents = DateComponents()
        (dateComponents as NSDateComponents).calendar = Calendar.current
        (dateComponents as NSDateComponents).timeZone = TimeZone(identifier: "GMT")!
        dateComponents.era = 1
        dateComponents.year = 1975
        dateComponents.month = 12
        dateComponents.day = 11
        dateComponents.hour = 22
        dateComponents.minute = 0
        dateComponents.second = 0
        return (dateComponents as NSDateComponents).date!
    }
    static let url1 = URL(string: "http://www.youtube.com/1")!
    static let url2 = URL(string: "http://www.youtube.com/2")!
    
    static let json1 = "{\"media\":[{\"date\":\"Fri, 05 Nov 1982 08:00:00 GMT\",\"id\":\"BEA9C47F-B002-4E84-91AD-582D0D19541D\",\"url\":\"http://www.youtube.com/1\",\"name\":\"Item 1\"},{\"date\":\"Thu, 11 Dec 1975 22:00:00 GMT\",\"id\":\"5C52425E-E45D-11E5-9730-9A79F06E9478\",\"url\":\"http://www.youtube.com/2\",\"name\":\"Item 2\"}],\"likes\":208,\"name\":\"Show Time\"}"
    static let json2 = "{\"media\":[{\"date\":\"Fri, 05 Nov 1982 08:00:00 GMT\",\"id\":\"BEA9C47F-B002-4E84-91AD-582D0D19541D\",\"url\":\"http://www.youtube.com/1\",\"name\":\"Item 1\"},{\"date\":\"Thu, 11 Dec 1975 22:00:00 GMT\",\"id\":\"5C52425E-E45D-11E5-9730-9A79F06E9478\",\"url\":\"http://www.youtube.com/2\",\"name\":\"Item 2\"}],\"name\":\"Show Time\",\"likes\":208}"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSerialization() {
        let channel = Channel()
        channel.name = "Show Time"
        channel.likes = 208
        
        let media1 = Media()
        media1.name = "Item 1"
        media1.id = SerializableObjectTests.uuid1
        media1.date = SerializableObjectTests.date1
        media1.url = SerializableObjectTests.url1
        
        let media2 = Media()
        media2.name = "Item 2"
        media2.id = SerializableObjectTests.uuid2
        media2.date = SerializableObjectTests.date2
        media2.url = SerializableObjectTests.url2
        
        channel.media = [media1, media2]
        
        let json = channel.json
        XCTAssertTrue(json == SerializableObjectTests.json1 || json == SerializableObjectTests.json2)
    }
    
    func testDeserialization() {
        let channel = Channel(withJSON: SerializableObjectTests.json1)
        XCTAssertTrue(channel.name == "Show Time")
        XCTAssertTrue(channel.likes == 208)
        
        guard let media = channel.media else {
            XCTFail()
            return
        }
        
        let m1 = media.filter { (m: Media) -> Bool in
            return m.name == "Item 1"
        }
        
        guard let media1 = m1.first else {
            XCTFail()
            return
        }
        
        if let id = media1.id, let date = media1.date, let url = media1.url {
            XCTAssertTrue(id == SerializableObjectTests.uuid1)
            XCTAssertTrue(date == SerializableObjectTests.date1)
            XCTAssertTrue(url == SerializableObjectTests.url1)
        } else {
            XCTFail()
            return
        }
        
        let m2 = media.filter { (m: Media) -> Bool in
            return m.name == "Item 2"
        }
        
        guard let media2 = m2.first else {
            XCTFail()
            return
        }
        
        if let id = media2.id, let date = media2.date, let url = media2.url {
            XCTAssertTrue(id == SerializableObjectTests.uuid2)
            XCTAssertTrue(date == SerializableObjectTests.date2)
            XCTAssertTrue(url == SerializableObjectTests.url2)
        } else {
            XCTFail()
            return
        }
    }
}
