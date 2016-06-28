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
    case Exception = 5
    
    var description: String {
        switch self {
        case .Verbose: return "Verbose"
        case .Debug: return "Debug"
        case .Info: return "Info"
        case .Warn: return "Warn"
        case .Error: return "Error"
        case .Exception: return "Exception"
        }
    }
}

public protocol LoggerAgent {
    func log(level: LoggerLevel, message: String?, error: NSError?, type: AnyClass?)
}

/// Provides a single logger that allows for extension by proxying requests to `LoggerAgents`.
/// The classes in CodeQuickKit use the Logger, add a `LoggerAgent` if you wish to process the log to another service.
public class Logger {
    public static var minimumConsoleLevel: LoggerLevel = .Debug
    public static var agents: [LoggerAgent] = [LoggerAgent]()
    
    public static func verbose(message: String, callingClass: AnyClass? = nil) {
        log(.Verbose, message: message, error: nil, type: callingClass)
    }
    
    public static func debug(message: String, callingClass: AnyClass? = nil) {
        log(.Debug, message: message, error: nil, type: callingClass)
    }
    
    public static func info(message: String, callingClass: AnyClass? = nil) {
        log(.Info, message: message, error: nil, type: callingClass)
    }
    
    public static func warn(message: String, callingClass: AnyClass? = nil) {
        log(.Warn, message: message, error: nil, type: callingClass)
    }
    
    public static func error(error: NSError?, message: String, callingClass: AnyClass? = nil) {
        log(.Error, message: message, error: error, type: callingClass)
    }
    
    public static func exception(exception: NSException?, message: String, callingClass: AnyClass? = nil) {
        var error: NSError?
        if let ex = exception {
            var userInfo:[NSObject : AnyObject] = [NSObject : AnyObject]()
            userInfo[NSLocalizedDescriptionKey] = ex.name
            userInfo[NSLocalizedFailureReasonErrorKey] = ex.reason ?? "Unknown Reason"
            if let dictionary = ex.userInfo {
                for (key, value) in dictionary {
                    userInfo[key] = value
                }
            }
            error = NSError(domain: String(self), code: 0, userInfo: userInfo)
        }
        log(.Exception, message: message, error: error, type: callingClass)
    }
    
    static func log(level: LoggerLevel, message: String?, error: NSError?, type: AnyClass?) {
        if level.rawValue >= minimumConsoleLevel.rawValue {
            let messageString = (message != nil) ? message! : ""
            let typeString = (type != nil) ? String(type!) : String(self)
            if let e = error {
                NSLog("[%@] %@ %@\n%@", level.description, typeString, messageString, e)
            } else {
                NSLog("[%@] %@ %@", level.description, typeString, messageString)
            }
        }
        
        for agent in agents {
            agent.log(level, message: message, error: error, type: type)
        }
    }
}
