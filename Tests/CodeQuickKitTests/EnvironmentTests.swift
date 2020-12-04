import XCTest
@testable import CodeQuickKit

class EnvironmentTests: XCTestCase {

    static var allTests = [
        ("testEnvironmentVariables", testEnvironmentVariables),
    ]

    func testEnvironmentVariables() {
        let platform = Platform.current
        let architecture = Architecture.current
        let release = Release.current
        print("Current Environment - Platform: \(platform) Arch: \(architecture) Release: \(release)")
        
        switch platform {
        case .macOS, .iOS, .tvOS, .watchOS, .linux:
            break
        default:
            XCTFail("Untested Platform: \(platform)")
        }
        
        switch architecture {
        case .arm, .arm64, .x86_64:
            break
        default:
            XCTFail("Untested Architecture: \(architecture)")
        }
        
        switch release {
        case .swift5_3, .swift5_2, .swift5_1, .swift5_0:
            break
        default:
            XCTFail("Untested Release: \(release)")
        }
    }

}
