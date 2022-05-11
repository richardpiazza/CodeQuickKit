import XCTest
@testable import CodeQuickKit

fileprivate protocol ExampleService {
    func getData() -> String
}

final class DependencyTests: XCTestCase {
    
    private let cache = DependencyCache()
    
    private class ConcreteService: ExampleService {
        var data: String
        
        init(defaultData: String = "") {
            data = defaultData
        }
        
        func getData() -> String { data }
    }
    
    private class Supplier: DependencySupplier {
        private let defaultData: String
        lazy var service = ConcreteService(defaultData: defaultData)
        
        init(defaultData: String = "Initial") {
            self.defaultData = defaultData
        }
        
        func supply(cache: DependencyCache) {
            cache.cache { self.service }
            cache.cache { self.service as ExampleService }
        }
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        cache.configure(with: Supplier())
    }
    
    /// Verify that typed references access the same underlying object reference.
    func testTypedResolver() {
        @Dependency(cache: cache) var exampleService: ExampleService
        @Dependency(cache: cache) var concreteService: ConcreteService
        
        XCTAssertEqual(exampleService.getData(), "Initial")
        concreteService.data = "Modified"
        XCTAssertEqual(concreteService.getData(), "Modified")
        XCTAssertEqual(exampleService.getData(), "Modified")
    }
    
    /// Verify that a dependency reference can be dissolved and resolved upon next access.
    func testDependencyDissolve() {
        @Dependency(cache: cache) var example1: ExampleService
        XCTAssertEqual(example1.getData(), "Initial")
        @Dependency(cache: cache) var example2: ExampleService
        XCTAssertEqual(example2.getData(), "Initial")
        
        _example1.dissolve()
        cache.configure(with: Supplier(defaultData: "Re-supply"))
        
        XCTAssertEqual(example1.getData(), "Re-supply")
        XCTAssertEqual(example2.getData(), "Initial")
    }
}
