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
        
        #if os(macOS)
            #if arch(x86_64)
                // Device
            #else
                XCTFail("Untested Architecture")
            #endif
        #elseif os(iOS)
            #if arch(x86_64)
                // Simulator
            #elseif (arch(arm) || arch(arm64))
                // Device
            #else
                XCTFail("Untested Architecture")
            #endif
        #elseif os(tvOS)
            #if arch(x86_64)
                // Simulator
            #elseif (arch(arm) || arch(arm64))
                // Device
            #else
                XCTFail("Untested Architecture")
            #endif
        #elseif os(watchOS)
            #if arch(x86_64)
                // Simulator
            #elseif (arch(arm) || arch(arm64))
                // Device
            #else
                XCTFail("Untested Architecture")
            #endif
        #else
            XCTFail("Untested Platform")
        #endif
    }

}
