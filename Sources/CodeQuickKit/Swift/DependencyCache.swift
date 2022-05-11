/// Collection of service and configuration dependencies.
///
/// On the initialization of an application, dependencies should be provided to the cache. Commonly,
/// these references are maintained by one or more sources. An example implementation on iOS would be:
/// ```swift
/// @UIApplicationMain
/// class AppDelegate: UIResponder, UIApplicationDelegate {
///     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///         DependencyCache.configure(with: Supplier())
///
///         return true
///     }
/// }
/// ```
///
/// See `DependencySupplier` for additional details.
public class DependencyCache {
    
    public enum Error: Swift.Error {
        case source(Any.Type)
        case type(Any.Type)
    }
    
    public static var shared: DependencyCache = .init()
    
    /// Dependencies maintained by the cache
    ///
    /// - note: `ObjectIdentifier` provides a hashable reference to a specific type being cached.
    private var dependencies: [ObjectIdentifier: () -> Any] = [:]
    
    public init() {
    }
    
    /// Add a dependency to the cache.
    public func cache<T>(dependency: @escaping () -> T) {
        dependencies[ObjectIdentifier(T.self)] = dependency
    }
    
    /// Resolve a dependency stored in the cache.
    ///
    /// - throws `DependencyCache.Error`
    /// - returns The resolved dependency for the request type.
    public func resolve<T>() throws -> T {
        guard let source = dependencies[ObjectIdentifier(T.self)] else {
            throw Error.source(T.self)
        }
        
        guard let dependency = source() as? T else {
            throw Error.type(T.self)
        }
        
        return dependency
    }
    
    /// Configures the cache with a `DependencySupplier`.
    public func configure(with supplier: DependencySupplier) {
        supplier.supply(cache: self)
    }
}

public extension DependencyCache {
    /// Add a dependency to the `.shared` cache.
    static func cache<T>(dependency: @escaping () -> T) {
        DependencyCache.shared.cache(dependency: dependency)
    }
    
    /// Resolve a dependency stored in the `.shared` cache.
    ///
    /// - throws `DependencyCache.Error`
    /// - returns The resolved dependency for the request type.
    static func resolve<T>() throws -> T {
        try DependencyCache.shared.resolve()
    }
    
    /// Configures the `.shared` cache with a `DependencySupplier`.
    static func configure(with supplier: DependencySupplier) {
        DependencyCache.shared.configure(with: supplier)
    }
}
