import XCTest
@testable import CodeQuickKit

class NSNumberFormatterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIntegerFormatter() {
        guard let number = NumberFormatter.integer(fromString: "25.5") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(number == 25)
        
        guard let string = NumberFormatter.string(fromInteger: number) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(string == "25")
    }
    
    func testSingleDecimalFormatter() {
        guard let number = NumberFormatter.singleDecimal(fromString: "147.3627") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(number == 147.362701)
        
        guard let string = NumberFormatter.string(fromSingleDecimal: number) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(string == "147.4")
    }
    
    func testDecimalFormatter() {
        guard let number = NumberFormatter.decimal(fromString: "999") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(number == 999.0)
        
        guard let string = NumberFormatter.string(fromDecimal: number) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(string == "999")
    }
    
    func testCurrencyFormatter() {
        guard let currencySymbol = NumberFormatter.currencyFormatter().currencySymbol else {
            // No Currency Symbol in currect environment
            return
        }
        
        guard let number = NumberFormatter.currency(fromString: "\(currencySymbol)84.55") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(number == 84.55)
        
        guard let string = NumberFormatter.string(fromCurrency: number) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(string == "\(currencySymbol)84.55")
    }
    
    func testPercentFormatter() {
        guard let percentSymbol = NumberFormatter.percentFormatter().percentSymbol else {
            // No Percent Symbol in current environment
            return
        }
        
        guard let number = NumberFormatter.percent(fromString: "69.75\(percentSymbol)") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(number == 0.6975)
        
        guard let string = NumberFormatter.string(fromPercent: number) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(string == "69.75\(percentSymbol)")
    }
}
