#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    
import Foundation

public typealias PausableTimerExpiredCompletion = () -> Void
public protocol PausableTimerDelegate {
    func pausableTimer(_ timer: PausableTimer, percentComplete: Double)
}

/// PausableTimer
/// Implements a timer that can be paused/resumed. Has options for 
/// delegate callbacks of status or a expiry completion handler.
public class PausableTimer {
    fileprivate let maxPercentComplete: Double = 1.0
    fileprivate var completedIntervals: TimeInterval = 0.0
    fileprivate var referenceDate: Date?
    
    public var timeInterval: TimeInterval
    public var delegate: PausableTimerDelegate?
    public var delegateRefreshRate: Float = 0.1
    public var expireCompletion: PausableTimerExpiredCompletion?
    
    /// Instantiates a new PausabelTimer and automatically 'resumes' the execution.
    public static func makeTimer(timeInterval: TimeInterval, delegate: PausableTimerDelegate? = nil, expireCompletion: PausableTimerExpiredCompletion? = nil) -> PausableTimer {
        let timer = PausableTimer(timeInterval: timeInterval, delegate: delegate, expireCompletion: expireCompletion)
        timer.resume()
        return timer
    }
    
    public static func makeTimer(timeInterval: TimeInterval, delegate: PausableTimerDelegate) -> PausableTimer {
        return makeTimer(timeInterval: timeInterval, delegate: delegate, expireCompletion: nil)
    }
    
    public static func makeTimer(timeInterval: TimeInterval, expireCompletion: @escaping PausableTimerExpiredCompletion) -> PausableTimer {
        return makeTimer(timeInterval: timeInterval, delegate: nil, expireCompletion: expireCompletion)
    }
    
    public init(timeInterval: TimeInterval, delegate: PausableTimerDelegate? = nil, expireCompletion: PausableTimerExpiredCompletion? = nil) {
        self.timeInterval = timeInterval
        self.delegate = delegate
        self.expireCompletion = expireCompletion
    }
    
    public convenience init(timeInterval: TimeInterval, delegate: PausableTimerDelegate) {
        self.init(timeInterval: timeInterval, delegate: delegate, expireCompletion: nil)
    }
    
    public convenience init(timeInterval: TimeInterval, expireCompletion: @escaping PausableTimerExpiredCompletion) {
        self.init(timeInterval: timeInterval, delegate: nil, expireCompletion: expireCompletion)
    }
    
    deinit {
        expireCompletion = nil
        delegate = nil
        referenceDate = nil
    }
    
    public var isActive: Bool {
        return referenceDate != nil
    }
    
    public var percentComplete: Double {
        let percent = completedIntervals / timeInterval
        return min(percent, maxPercentComplete)
    }
    
    fileprivate var dispatchTime: DispatchTime {
        return DispatchTime.now() + Double(Int64(delegateRefreshRate * Float(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    }
    
    /// Resets the timer to the inital state and begins counting.
    public func reset() {
        completedIntervals = 0
        resume()
    }
    
    /// Pauses the timer
    public func pause() {
        referenceDate = nil
    }
    
    /// Resumes the timer
    public func resume() {
        referenceDate = Date(timeIntervalSinceNow: -completedIntervals)
        update()
    }
    
    /// Calculates the number of completed intervals and notifies the delegate.
    fileprivate func update() {
        guard let referenceDate = self.referenceDate else {
            return
        }
        
        completedIntervals = Date().timeIntervalSince(referenceDate)
        
        let percent = percentComplete
        
        guard percent < maxPercentComplete else {
            expire()
            return
        }
        
        if let delegate = self.delegate {
            delegate.pausableTimer(self, percentComplete: percent)
        }
        
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: dispatchTime) {
            self.update()
        }
    }
    
    /// Terminates the execution of the timer and notifies delegates.
    fileprivate func expire() {
        referenceDate = nil
        if let delegate = self.delegate {
            delegate.pausableTimer(self, percentComplete: maxPercentComplete)
        }
        if let expireCompletion = self.expireCompletion {
            expireCompletion()
        }
    }
}

#endif
