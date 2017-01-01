//
//  LogManagerTests.swift
//  CodeQuickKit
//
//  Created by Richard Piazza on 12/31/16.
//  Copyright © 2016 Richard Piazza. All rights reserved.
//

import XCTest
@testable import CodeQuickKit

class LogManagerTests: XCTestCase {
    
    var logFile = LogFile.default
    
    override func setUp() {
        super.setUp()
        
        Log.consoleLevel = .debug
        Log.writeToFile = true
        
        logFile.logLevel = .debug
        logFile.purge()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLog() {
        XCTAssertFalse(FileManager.default.fileExists(atPath: logFile.url.path))
        
        Log.debug("doh...")
        Log.info("FYI...")
        Log.warn("Danger Will Robinson...")
        Log.error("Shit just hit the fan...", error: NSError(domain: "LogManagerTests", code: 0, userInfo: nil))
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: logFile.url.path))
    }
}
