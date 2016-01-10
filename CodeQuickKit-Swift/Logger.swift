//===----------------------------------------------------------------------===//
//
// Logger.swift
//
// Copyright (c) 2016 Richard Piazza
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

public enum LoggerLevel: Int {
    case Verbose = 0
    case Debug = 1
    case Info = 2
    case Warn = 3
    case Error = 4
    
    func stringValue() -> String {
        switch self {
        case .Verbose: return "Verbose"
        case .Debug: return "Debug"
        case .Info: return "Info"
        case .Warn: return "Warn"
        case .Error: return "Error"
        }
    }
}

public protocol LoggerAgent {
    func log(level: LoggerLevel, message: String?, error: NSError?, type: AnyClass?)
}

public class Logger {
    public static var minimumConsoleLevel: LoggerLevel = .Debug
    public static var agents: [LoggerAgent] = [LoggerAgent]()
    
    public static func logVerbose(withMessage message: String) {
        log(.Verbose, message: message, error: nil, type: Logger.self)
    }
    
    public static func logVerbose(withFormat format: String, args: CVarArgType...) {
        let pointer = getVaList(args)
        let message = NSString(format: format, arguments: pointer)
        logVerbose(withMessage: message as String)
    }
    
    public static func logDebug(withMessage message: String) {
        log(.Debug, message: message, error: nil, type: Logger.self)
    }
    
    public static func logDebug(withFormat format: String, args: CVarArgType...) {
        let pointer = getVaList(args)
        let message = NSString(format: format, arguments: pointer)
        logDebug(withMessage: message as String)
    }
    
    public static func logInfo(withMessage message: String) {
        log(.Info, message: message, error: nil, type: Logger.self)
    }
    
    public static func logInfo(withFormat format: String, args: CVarArgType...) {
        let pointer = getVaList(args)
        let message = NSString(format: format, arguments: pointer)
        logInfo(withMessage: message as String)
    }
    
    public static func logWarn(withMessage message: String) {
        log(.Warn, message: message, error: nil, type: Logger.self)
    }
    
    public static func logWarn(withFormat format: String, args: CVarArgType...) {
        let pointer = getVaList(args)
        let message = NSString(format: format, arguments: pointer)
        logWarn(withMessage: message as String)
    }
    
    public static func logError(withError error: NSError?, message: String) {
        log(.Error, message: message, error: error, type: Logger.self)
    }
    
    public static func logError(withError error: NSError?, format: String, args: CVarArgType...) {
        let pointer = getVaList(args)
        let message = NSString(format: format, arguments: pointer)
        logError(withError: error, message: message as String)
    }
    
    static func log(level: LoggerLevel, message: String?, error: NSError?, type: AnyClass?) {
        if level.rawValue >= minimumConsoleLevel.rawValue {
            let messageString = (message != nil) ? message! : ""
            let typeString = (type != nil) ? NSStringFromClass(type!) : "Logger"
            if error != nil {
                NSLog("[%@] (Class: %@), %@\n%@", level.stringValue(), typeString, messageString, error!)
            } else {
                NSLog("[%@] (Class: %@), %@", level.stringValue(), typeString, messageString)
            }
        }
        
        for agent in agents {
            agent.log(level, message: message, error: error, type: type)
        }
    }
}
