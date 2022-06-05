import XCTest
@testable import CodeQuickKit

final class UserDefaultTests: XCTestCase {
    
    let defaults = UserDefaults()
    
    override func tearDownWithError() throws {
        defaults.removeObject(forKey: "name")
        defaults.removeObject(forKey: "age")
        defaults.removeObject(forKey: "job")
        
        try super.tearDownWithError()
    }
    
    func testWrappedValue() {
        var name: String? = defaults.object(forKey: "name") as? String
        var age: Int? = defaults.object(forKey: "age") as? Int
        XCTAssertNil(name)
        XCTAssertNil(age)
        
        @UserDefault("name", store: defaults, defaultValue: "Bob") var userName: String
        @UserDefault("age", store: defaults, defaultValue: 47) var userAge: Int
        
        XCTAssertEqual(userName, "Bob")
        XCTAssertEqual(userAge, 47)
        
        name = defaults.object(forKey: "name") as? String
        age = defaults.object(forKey: "age") as? Int
        XCTAssertNil(name)
        XCTAssertNil(age)
        
        userName = "Nancy"
        userAge = 83
        
        name = defaults.object(forKey: "name") as? String
        age = defaults.object(forKey: "age") as? Int
        XCTAssertEqual(name, "Nancy")
        XCTAssertEqual(age, 83)
        
        @UserDefault("job", store: defaults, defaultValue: nil) var userJob: String?
        XCTAssertNil(userJob)
        userJob = "Teacher"
        
        let job = defaults.object(forKey: "job") as? String
        XCTAssertEqual(job, "Teacher")
    }
}
