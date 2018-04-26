import XCTest
@testable import CodeQuickKit

class EnvironmentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEnvironmentVariables() {
        let platform = Environment.platform
        let architecture = Environment.architecture
        let release = Environment.release
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
