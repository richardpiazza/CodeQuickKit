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
    
    lazy var log: Log = {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("logTests.txt")
        let log = Log(fileUrl: url)
        log.minimumConsoleLevel = .debug
        log.minimumFileLevel = .debug
        return log
    }()
    
    override func setUp() {
        super.setUp()
        
        log.clear()
    }
    
    override func tearDown() {
        guard let url = log.fileUrl else {
            super.tearDown()
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        super.tearDown()
    }
    
    enum TestError: Error {
        case fanError
    }
    
    func testLog() {
        let url = log.fileUrl!
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        
        log.debug("doh...")
        log.info("FYI...")
        log.warn("Danger Will Robinson...")
        log.error("Feces just impacted the oscillating device...", error: TestError.fanError)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }
}
