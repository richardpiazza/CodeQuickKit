import Foundation

#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
public extension Bundle {
    /// Attempts to determine the "full" modularized name for a given class.
    /// For example: when using CodeQuickKit as a module, the moduleClass for
    /// the `WebAPI` class would be `CodeQuickKit.WebAPI`.
    func moduleClass(forClassNamed classNamed: String) -> AnyClass {
        var moduleClass: AnyClass? = NSClassFromString(classNamed)
        if moduleClass != nil && moduleClass != NSNull.self {
            return moduleClass!
        }
        
        if let prefix = bundleDisplayName {
            let underscored = prefix.replacingOccurrences(of: " " , with: "_")
            moduleClass = NSClassFromString("\(underscored).\(classNamed)")
            if moduleClass != nil && moduleClass != NSNull.self {
                return moduleClass!
            }
        }
        
        if let prefix = bundleName {
            let underscored = prefix.replacingOccurrences(of: " " , with: "_")
            moduleClass = NSClassFromString("\(underscored).\(classNamed)")
            if moduleClass != nil && moduleClass != NSNull.self {
                return moduleClass!
            }
        }
        
        return NSNull.self
    }
    
    /// Takes the moduleClass for a given class and attempts to singularize it.
    func singularizedModuleClass(forClassNamed classNamed: String) -> AnyClass {
        var moduleClass: AnyClass? = self.moduleClass(forClassNamed: classNamed)
        if moduleClass != nil && moduleClass != NSNull.self {
            return moduleClass!
        }
        
        let firstRange = classNamed.startIndex..<classNamed.index(classNamed.startIndex, offsetBy: 1)
        let endRange = classNamed.index(classNamed.endIndex, offsetBy: -1)..<classNamed.endIndex
        
        var singular = classNamed
        singular.replaceSubrange(firstRange, with: singular[firstRange].uppercased())
        if singular.lowercased().hasSuffix("s") {
            singular.replaceSubrange(endRange, with: "")
        }
        
        moduleClass = self.moduleClass(forClassNamed: singular)
        if moduleClass != nil && moduleClass != NSNull.self {
            return moduleClass!
        }
        
        return NSNull.self
    }
}
#endif
