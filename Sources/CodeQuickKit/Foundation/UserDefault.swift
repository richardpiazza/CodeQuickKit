import Foundation

///Property wrapper that allows for direct access to `UserDefaults` values.
@propertyWrapper public struct UserDefault<T> {
    
    public struct Identifier: ExpressibleByStringLiteral {
        public let rawValue: String
        public init(stringLiteral rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public let identifier: Identifier
    public var storage: UserDefaults
    private let defaultValue: T
    
    /// Initialize a `UserDefault` wrapper.
    ///
    /// - parameters:
    ///   - identifier: A unique value that identifies the persisted value.
    ///   - store: The defaults instance responsible for storing the value
    ///   - defaultValue: A value that should be returned when the store has no value.
    public init(_ identifier: Identifier, store: UserDefaults = .standard, defaultValue: T) {
        self.identifier = identifier
        self.storage = store
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get { read() }
        set { update(newValue) }
    }
    
    /// Removes the value from the store
    public mutating func delete() {
        storage.removeObject(forKey: identifier.rawValue)
    }
    
    /// Loads the value from the store or return the `defaultValue` when no value exists.
    private func read() -> T {
        (storage.object(forKey: identifier.rawValue) as? T) ?? defaultValue
    }
    
    /// Persists the value in the store.
    private mutating func update(_ value: T) {
        if case Optional<Any>.none = (value as Any) {
            storage.removeObject(forKey: identifier.rawValue)
        } else {
            storage.set(value, forKey: identifier.rawValue)
        }
    }
}
