/// Convenience property wrapper that provides a type from the `DependencyCache`.
@propertyWrapper public struct Dependency<T> {
    
    private let cache: DependencyCache
    private(set) var value: T?
    
    public init(cache: DependencyCache = .shared) {
        self.cache = cache
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
    
    /// Resets the underlying dependency reference, forcing resolution on the next access.
    public mutating func dissolve() {
        value = nil
    }
}
