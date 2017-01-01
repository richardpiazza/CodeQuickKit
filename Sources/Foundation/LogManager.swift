//===----------------------------------------------------------------------===//
//
// LogManager.swift
//
// Copyright (c) 2017 Richard Piazza
// https://github.com/richardpiazza/CodeQuickKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//===----------------------------------------------------------------------===//

import Foundation

public class LogManager {
    public static var `default`: LogManager = LogManager()
    
    public private(set) var logAgents: [LogAgent] = [LogAgent]()
    public var consoleLevel: LogLevel = .debug
    public var fileLevel: LogLevel = .error
    public var logFile: LogFile = LogFile.default
    public var writeToFile: Bool = false
    
    private init() {
        
    }
    
    // MARK: - Agents
    private func index(of agent: LogAgent) -> Array<LogAgent>.Index? {
        let index = logAgents.index { (logAgent) -> Bool in
            return logAgent.isEqual(agent)
        }
        
        return index
    }
    
    public func add(agent: LogAgent) {
        if let _ = index(of: agent) {
            return
        }
        
        logAgents.append(agent)
    }
    
    public func remove(agent: LogAgent) {
        guard let index = index(of: agent) else {
            return
        }
        
        logAgents.remove(at: index)
    }
    
    // MARK: - Logging
    public func debug(file: String = #file, line: Int = #line, _ message: String) {
        log(.debug, file: file, line: line, message: message, error: nil)
    }
    
    public func info(file: String = #file, line: Int = #line, _ message: String) {
        log(.info, file: file, line: line, message: message, error: nil)
    }
    
    public func warn(file: String = #file, line: Int = #line, _ message: String) {
        log(.warn, file: file, line: line, message: message, error: nil)
    }
    
    public func error(file: String = #file, line: Int = #line, _ message: String? = nil, error: Error) {
        log(.error, file: file, line: line, message: message, error: error as NSError)
    }
    
    public func error(file: String = #file, line: Int = #line, _ message: String? = nil, error: NSError) {
        log(.error, file: file, line: line, message: message, error: error)
    }
    
    private func log(_ level: LogLevel, file: String, line: Int, message: String? = nil, error: NSError? = nil) {
        let url = URL(fileURLWithPath: file)
        
        var output: String
        if let m = message, let e = error {
            output = "[\(level.symbolValue) \(level.fixedSpaceStringValue) \(url.lastPathComponent) \(line)] \(m) | \(e)"
        } else if let m = message {
            output = "[\(level.symbolValue) \(level.fixedSpaceStringValue) \(url.lastPathComponent) \(line)] \(m)"
        } else if let e = error {
            output = "[\(level.symbolValue) \(level.fixedSpaceStringValue) \(url.lastPathComponent) \(line)] \(e)"
        } else {
            output = "[\(level.symbolValue) \(level.fixedSpaceStringValue) \(url.lastPathComponent) \(line)]"
        }
        
        if level.rawValue >= consoleLevel.rawValue {
            NSLog("%@", output)
        }
        
        if level.rawValue >= fileLevel.rawValue && writeToFile {
            logFile.write(output)
        }
            
        for agent in logAgents {
            agent.log(level, file: file, line: line, message: message, error: error)
        }
    }
}

public enum LogLevel: Int {
    case debug = 0
    case info = 1
    case warn = 2
    case error = 3
    
    public var stringValue: String {
        switch self {
        case .debug: return "Debug"
        case .info: return "Info"
        case .warn: return "Warn"
        case .error: return "Error"
        }
    }
    
    public var fixedSpaceStringValue: String {
        return stringValue.padding(toLength: 5, withPad: " ", startingAt: 0)
    }
    
    public var symbolValue: String {
        switch self {
        case .debug: return "⚪️"
        case .info: return "⚫️"
        case .warn: return "🔵"
        case .error: return "🔴"
        }
    }
}

public protocol LogAgent: NSObjectProtocol {
    func log(_ level: LogLevel, file: String, line: Int, message: String?, error: NSError?)
}

public class LogFile {
    public static var `default`: LogFile = LogFile(fileName: "log.txt")
    
    private var fileDirectory: URL {
        var urls: [URL]
        #if os(tvOS)
            urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        #else
            urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        #endif
        
        guard let url = urls.last else {
            fatalError("Could not find url for storage directory.")
        }
        
        return url
    }
    
    public var fileURL: URL {
        return fileDirectory.appendingPathComponent(fileName)
    }
    
    public private(set) var fileName: String
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    public func write(_ output: String) {
        guard let data = output.appending("\n").data(using: .utf8) else {
            return
        }
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            do {
                try data.write(to: fileURL, options: .atomic)
            } catch {
                NSLog("%@", error as NSError)
            }
            return
        }
        
        var handle: FileHandle
        do {
            handle = try FileHandle(forWritingTo: fileURL)
        } catch {
            NSLog("%@", error as NSError)
            return
        }
        
        handle.seekToEndOfFile()
        handle.write(data)
        handle.closeFile()
    }
    
    public func purge() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            NSLog("%@", error as NSError)
        }
    }
}
