import Foundation

public struct Environment {
    public static var platform: Platform {
        return Platform.current
    }
    
    public static var architecture: Architecture {
        return Architecture.current
    }
    
    public static var release: Release {
        return Release.current
    }
}

/// The supported Swift compilation OSs
public enum Platform {
    case other
    case macOS
    case iOS
    case watchOS
    case tvOS
    case linux
    case freeBSD
    case android
    case windows
    case ps4
    
    public static var current: Platform {
        #if os(macOS)
            return .macOS
        #elseif os(iOS)
            return .iOS
        #elseif os(watchOS)
            return .watchOS
        #elseif os(tvOS)
            return .tvOS
        #elseif os(Linux)
            return .linux
        #elseif os(FreeBSD)
            return .freeBSD
        #elseif os(Android)
            return .android
        #elseif os(Windows)
            return .windows
        #elseif os(PS4)
            return .ps4
        #else
            return .other
        #endif
    }
}

/// The supported Swift compilation architectures
public enum Architecture {
    case other
    case arm
    case arm64
    case i386
    case x86_64
    case powerpc64
    case powerpc64le
    case s390x
    
    public static var current: Architecture {
        #if arch(arm)
            return .arm
        #elseif arch(arm64)
            return .arm64
        #elseif arch(i386)
            return .i386
        #elseif arch(x86_64)
            return .x86_64
        #elseif arch(powerpc64)
            return .powerpc64
        #elseif arch(powerpc64le)
            return .powerpc64le
        #elseif arch(s390x)
            return .s390x
        #else
            return .other
        #endif
    }
}

/// Recent Swift milestone releases
public enum Release {
    case other
    case swift2_2
    case swift2_3
    case swift3_0
    case swift3_1
    case swift3_2
    case swift4_0
    
    public static var current: Release {
        #if swift(>=4.0)
            return .swift4_0
        #elseif swift(>=3.2)
            return .swift3_2
        #elseif swift(>=3.1)
            return .swift3_1
        #elseif swift(>=3.0)
            return .swift3_0
        #elseif swift(>=2.3)
            return .swift2_3
        #elseif swift(>=2.2)
            return .swift2_2
        #else
            return .other
        #endif
    }
}
