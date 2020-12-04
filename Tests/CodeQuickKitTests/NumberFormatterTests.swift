import XCTest
@testable import CodeQuickKit

class NumberFormatterTests: XCTestCase {
    
    static var allTests = [
        ("testIntegerFormatter", testIntegerFormatter),
        ("testSingleDecimalFormatter", testSingleDecimalFormatter),
        ("testDecimalFormatter", testDecimalFormatter),
        ("testCurrencyFormatter", testCurrencyFormatter),
        ("testPercentFormatter", testPercentFormatter),
    ]
    
    func testIntegerFormatter() throws {
        let number = try XCTUnwrap(NumberFormatter.integer(fromString: "25.5"))
        XCTAssertEqual(number, 25)
        
        let string = try XCTUnwrap(NumberFormatter.string(fromInteger: number))
        XCTAssertEqual(string, "25")
    }
    
    func testSingleDecimalFormatter() throws {
        let number = try XCTUnwrap(NumberFormatter.singleDecimal(fromString: "147.3627"))
        XCTAssertEqual(number, 147.3627, accuracy: 0.0001)
        
        let string = try XCTUnwrap(NumberFormatter.string(fromSingleDecimal: number))
        XCTAssertEqual(string, "147.4")
    }
    
    func testDecimalFormatter() throws {
        let number = try XCTUnwrap(NumberFormatter.decimal(fromString: "999"))
        XCTAssertEqual(number, 999.0)
        
        let string = try XCTUnwrap(NumberFormatter.string(fromDecimal: number))
        XCTAssertEqual(string, "999")
    }
    
    func testCurrencyFormatter() throws {
        let currencySymbol = NumberFormatter.currencyFormatter().currencySymbol
        try XCTSkipIf(currencySymbol == nil, "No Currency Symbol in current environment")
        
        let number = try XCTUnwrap(NumberFormatter.currency(fromString: "\(currencySymbol!)84.55"))
        XCTAssertEqual(number, 84.55)
        
        let string = try XCTUnwrap(NumberFormatter.string(fromCurrency: number))
        XCTAssertEqual(string, "\(currencySymbol!)84.55")
    }
    
    func testPercentFormatter() throws {
        let percentSymbol = NumberFormatter.percentFormatter().percentSymbol
        try XCTSkipIf(percentSymbol == nil, "No Percent Symbol in current environment")
        
        let number = try XCTUnwrap(NumberFormatter.percent(fromString: "69.75\(percentSymbol!)"))
        XCTAssertEqual(number, 0.6975)
        
        let string = try XCTUnwrap(NumberFormatter.string(fromPercent: number))
        XCTAssertEqual(string, "69.75\(percentSymbol!)")
    }
}
