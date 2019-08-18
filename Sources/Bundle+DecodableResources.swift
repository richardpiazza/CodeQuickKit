import Foundation

/// Extension to `Bundle` that adds `Decodable` support for JSON resources.
public extension Bundle {
    /// Finds the URL for a bundled resource and returns a `Data` representation.
    ///
    /// - parameter resource: The resource name (sans extension)
    /// - parameter extension: The resource extension (sans .)
    /// - throws: CocoaError
    /// - returns: A Data representation of the specified resource.
    func data(forResource resource: String, withExtension `extension`: String = "json") throws -> Data {
        guard let fileURL = self.url(forResource: resource, withExtension: `extension`) else {
            throw CocoaError(.fileNoSuchFile)
        }
        
        return try Data(contentsOf: fileURL, options: .mappedIfSafe)
    }
    
    /// Loads data from a bundle resource and decodes using the specified decoder.
    ///
    /// - parameter type: The `Decodable` type
    /// - parameter resource: The resource name (sans extension)
    /// - parameter extension: The resource extension (sans .)
    /// - parameter decoder: The JSONDecoder used to produce the `ofType` output.
    /// - throws: CocoaError / DecodingError
    /// - returns: An object of the specified `Decodable` type.
    func decodableData<T: Decodable>(ofType type: T.Type, forResource resource: String, withExtension `extension`: String = "json", usingDecoder decoder: JSONDecoder = JSONDecoder()) throws -> T {
        let data = try self.data(forResource: resource, withExtension: `extension`)
        return try decoder.decode(type, from: data)
    }
}
