import XCTest
@testable import CodeQuickKit

@available(*, deprecated, message: "See: https://github.com/richardpiazza/LocaleSupport")
class LocalizedStringExpressibleTests: XCTestCase {
    
    private static var indicators: (prefix: Character, suffix: Character)? = nil
    
    private enum Strings: String, LocalizedStringExpressible {
        case alertTitle = "Delete Document"
        case alertMessage = "Are you sure you want to delete the document?"
        case confirm = "Yes"
        case cancel = "Cancel"
        
        var prefix: String? {
            switch self {
            case .confirm:
                return "standard"
            default:
                return nil
            }
        }
        
        var defaultIndicators: (prefix: Character, suffix: Character)? {
            return LocalizedStringExpressibleTests.indicators
        }
    }
    
    func testKey() {
        XCTAssertEqual(Strings.alertTitle.key, "ALERT_TITLE")
        XCTAssertEqual(Strings.alertMessage.key, "ALERT_MESSAGE")
        XCTAssertEqual(Strings.confirm.key, "STANDARD_CONFIRM")
        XCTAssertEqual(Strings.cancel.key, "CANCEL")
    }
    
    func testDefault() {
        XCTAssertEqual(Strings.alertTitle.localizedValue, "Delete Document")
        XCTAssertEqual(Strings.alertMessage.localizedValue, "Are you sure you want to delete the document?")
        XCTAssertEqual(Strings.confirm.localizedValue, "Yes")
        XCTAssertEqual(Strings.cancel.localizedValue, "Cancel")
        
        Self.indicators = ("[", "]")
        
        XCTAssertEqual(Strings.alertTitle.localizedValue, "[Delete Document]")
        XCTAssertEqual(Strings.alertMessage.localizedValue, "[Are you sure you want to delete the document?]")
        XCTAssertEqual(Strings.confirm.localizedValue, "[Yes]")
        XCTAssertEqual(Strings.cancel.localizedValue, "[Cancel]")
        
        Self.indicators = nil
    }
}
