/// A supplier of dependencies.
///
/// Here's an example implementation.
///
/// ```swift
/// class Supplier: DependencySupplier {
///     lazy var networkService: NetworkService { RealNetworkService() }
///     lazy var tokenAuthService: TokenAuthService { RealTokenAuthService() }
///
///     func supply(cache: DependencyCache) {
///         cache.cache { self.networkService }
///         cache.cache { self.tokenAuthService }
///         cache.cache { self.tokenAuthService as TokenService }
///     }
/// }
/// ```
///
/// In this example, the `TokenAuthService` is a concrete class which conforms to the `TokenService`
/// protocol. When supplying the `resolver`, it is provided as the implementation and as a protocol
/// reference. This allows for any dependency references to either the type or the protocol:
///
/// ```swift
/// @Dependency var tokenService: TokenService
/// @Dependency var authService: TokenAuthService
/// ```
///
/// Both resolve to the same instance.
public protocol DependencySupplier {
    /// Provide dependencies to the cache.
    func supply(cache: DependencyCache)
}
