/// Collection of service and configuration dependencies.
///
/// On the initialization of an application, dependencies should be provided to the cache. Commonly,
/// these references are maintained by one or more sources. An example implementation on iOS would be:
/// ```swift
/// @UIApplicationMain
/// class AppDelegate: UIResponder, UIApplicationDelegate {
///     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///         let dependencySource = Dependencies()
///         dependencySource.cacheDependencies()
///
///         return true
///     }
/// }
///
/// class Dependencies {
///     lazy var service: ServiceProtocol = ServiceProtocolImplementation()
///
///     init() {
///     }
///
///     func cacheDependencies() {
///         DependencyCache.cache { self.service }
///     }
/// }
/// ```
public class DependencyCache {
    
    public enum Error: Swift.Error {
        case source(Any.Type)
        case type(Any.Type)
    }
    
    /// Dependencies maintained by the cache
    ///
    /// - note: `ObjectIdentifier` provides a hashable reference to a specific type being cached.
    private static var dependencies: [ObjectIdentifier: () -> Any] = [:]
    
    private init() {
    }
    
    /// Add a dependency to the cache.
    public static func cache<T>(dependency: @escaping () -> T) {
        dependencies[ObjectIdentifier(T.self)] = dependency
    }
    
    /// Resolve a dependency stored in the cache.
    ///
    /// - throws `DependencyCache.Error`
    /// - returns The resolved dependency for the request type.
    public static func resolve<T>() throws -> T {
        guard let source = dependencies[ObjectIdentifier(T.self)] else {
            throw Error.source(T.self)
        }
        
        guard let dependency = source() as? T else {
            throw Error.type(T.self)
        }
        
        return dependency
    }
}
