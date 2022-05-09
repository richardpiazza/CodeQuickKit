/// Convenience property wrapper that provides a type from the `DependencyCache`.
@propertyWrapper public struct Dependency<T> {
    
    private let cache: DependencyCache = .shared
    private(set) var value: T?
    
    public init() {
    }
    
    public var wrappedValue: T {
        mutating get {
            guard let value = self.value else {
                do {
                    let resolved: T = try cache.resolve()
                    self.value = resolved
                    return resolved
                } catch {
                    preconditionFailure("Failed to resolve dependency of type '\(String(describing: T.self))'.")
                }
            }
            
            return value
        } set {
            value = newValue
        }
    }
    
    public mutating func dissolve() {
        value = nil
    }
}
