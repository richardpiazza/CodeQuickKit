import Foundation

/// A general purpose logging class providing console, file, and observer logging
/// abilities.
/// - note: CodeQuickKit uses this class for its logging.
public struct Log {
    public private(set) static var observers: [LogObserver] = [LogObserver]()
    public static var consoleLevel: LogLevel = .debug
    
    #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    public static var writeToFile: Bool = false {
        didSet {
            if writeToFile {
                add(observer: LogFile.default)
            } else {
                remove(observer: LogFile.default)
            }
        }
    }
    #endif
    
    // MARK: - Observers
    private static func index(of observer: LogObserver) -> Array<LogObserver>.Index? {
        let index = observers.index { (o: LogObserver) -> Bool in
            return o.isEqual(observer)
        }
        
        return index
    }
    
    public static func add(observer: LogObserver) {
        if let _ = index(of: observer) {
            return
        }
        
        observers.append(observer)
    }
    
    public static func remove(observer: LogObserver) {
        guard let index = index(of: observer) else {
            return
        }
        
        observers.remove(at: index)
    }
    
    // MARK: - Logging
    public static func debug(file: String = #file, line: Int = #line, _ message: String) {
        log(.debug, file: file, line: line, message: message, error: nil)
    }
    
    public static func info(file: String = #file, line: Int = #line, _ message: String) {
        log(.info, file: file, line: line, message: message, error: nil)
    }
    
    public static func warn(file: String = #file, line: Int = #line, _ message: String) {
        log(.warn, file: file, line: line, message: message, error: nil)
    }
    
    public static func error(file: String = #file, line: Int = #line, _ error: Error? = nil, message: String? = nil) {
        log(.error, file: file, line: line, message: message, error: error)
    }
    
    private static func log(_ level: LogLevel, file: String, line: Int, message: String? = nil, error: Error? = nil) {
        let log = Log(level, file: file, line: line, message: message, error: error)
        
        if level.rawValue >= consoleLevel.rawValue {
            print(log.stringValue)
        }
        
        for observer in observers {
            observer.log(log)
        }
    }
    
    public var level: LogLevel
    public var date: Date
    public var file: String
    public var line: Int
    public var message: String?
    public var error: Error?
    
    public init(_ level: LogLevel, date: Date = Date(), file: String = #file, line: Int = #line, message: String? = nil, error: Error? = nil) {
        self.level = level
        self.date = date
        self.file = file
        self.line = line
        self.message = message
        self.error = error
    }
    
    public var stringValue: String {
        let url = URL(fileURLWithPath: file)
        
        if let m = message, let e = error {
            return "[\(date) \(level.gem) \(level.fixedSpaceStringValue) \(url.lastPathComponent) \(line)] \(m) | \(e.localizedDescription)"
        } else if let m = message {
            return "[\(date) \(level.gem) \(level.fixedSpaceStringValue) \(url.lastPathComponent) \(line)] \(m)"
        } else if let e = error {
            return "[\(date) \(level.gem) \(level.fixedSpaceStringValue) \(url.lastPathComponent) \(line)] \(e.localizedDescription)"
        } else {
            return "[\(date) \(level.gem) \(level.fixedSpaceStringValue) \(url.lastPathComponent) \(line)]"
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
    
    /// A string with fixed spacing, representing the log levels.
    public var fixedSpaceStringValue: String {
        return stringValue.padding(toLength: 5, withPad: " ", startingAt: 0)
    }
    
    /// A string with a colored emoji representing the log levels.
    public var gem: String {
        switch self {
        case .debug: return "⚪️"
        case .info: return "⚫️"
        case .warn: return "🔵"
        case .error: return "🔴"
        }
    }
}

public protocol LogObserver: NSObjectProtocol {
    func log(_ log: Log)
}

/// A Simple class conforming to `LogObserver` that writes `Log`s to a file on disk.
public class LogFile: NSObject, LogObserver {
    #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    public static var `default`: LogFile = LogFile(fileName: "log.txt", logLevel: .debug, autoPurge: true)
    #endif
    
    private static var fileDirectory: URL {
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
    
    public var url: URL
    public var logLevel: LogLevel
    
    public init(url: URL, logLevel: LogLevel = .error, autoPurge: Bool = false) {
        self.url = url
        self.logLevel = logLevel
        super.init()
        
        if autoPurge {
            self.autoPurge()
        }
    }
    
    #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    public convenience init(fileName: String, logLevel: LogLevel = .error, autoPurge: Bool = false) {
        let url = type(of: self).fileDirectory.appendingPathComponent(fileName)
        self.init(url: url, logLevel: logLevel, autoPurge: autoPurge)
    }
    #endif
    
    public func log(_ log: Log) {
        guard log.level.rawValue >= logLevel.rawValue else {
            return
        }
        
        guard let data = log.stringValue.appending("\n").data(using: .utf8) else {
            return
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                print(error)
            }
            return
        }
        
        var handle: FileHandle
        do {
            handle = try FileHandle(forWritingTo: url)
        } catch {
            print(error)
            return
        }
        
        let _ = handle.seekToEndOfFile()
        handle.write(data)
        handle.closeFile()
    }
    
    /// Automatically purges the file at `URL` when reaching `bytes`.
    /// By default this will purge at 1MB.
    public func autoPurge(_ bytes: UInt = (1024 * 1024 * 1)) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        
        let attributes: [FileAttributeKey : Any]
        do {
            attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        } catch {
            print(error)
            return
        }
        
        guard let fileBytes = attributes[FileAttributeKey.size] as? UInt else {
            return
        }
        
        guard fileBytes > bytes else {
            return
        }
        
        purge()
    }
    
    public func purge() {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
    }
    
    public var data: Data? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        var data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            print(error)
            return nil
        }
        
        return data
    }
}
