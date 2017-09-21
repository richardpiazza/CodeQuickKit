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
    
    lazy var logFile: LogFile = {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("logTests.txt")
        return LogFile(url: url, logLevel: .debug, autoPurge: true)
    }()
    
    override func setUp() {
        super.setUp()
        
        Log.consoleLevel = .debug
        Log.add(observer: logFile)
        logFile.logLevel = .debug
        logFile.purge()
    }
    
    override func tearDown() {
        Log.remove(observer: logFile)
        do {
            try FileManager.default.removeItem(at: logFile.url)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        super.tearDown()
    }
    
    enum TestError: Error {
        case fanError
    }
    
    func testLog() {
        XCTAssertFalse(FileManager.default.fileExists(atPath: logFile.url.path))
        
        Log.debug("doh...")
        Log.info("FYI...")
        Log.warn("Danger Will Robinson...")
        Log.error(TestError.fanError, message: "Shit just hit the fan...")
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: logFile.url.path))
    }
}
