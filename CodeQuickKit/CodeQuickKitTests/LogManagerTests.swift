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
    
    private var log = LogManager.default
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLog() {
        let logFile = log.logFile
        
        logFile.purge()
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: logFile.fileURL.path))
        
        log.consoleLevel = .debug
        log.fileLevel = .debug
        log.writeToFile = true
        
        log.debug("doh...")
        log.info("FYI...")
        log.warn("Danger Will Robinson...")
        log.error("Shit just hit the fan...", error: NSError(domain: "LogManagerTests", code: 0, userInfo: nil))
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: logFile.fileURL.path))
    }
}
