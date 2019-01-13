import Foundation

public extension HTTP {
    public typealias CodableTaskCompletion<D: Decodable> = (_ statusCode: Int, _ headers: Headers?, _ data: D?, _ error: Swift.Error?) -> Void
}

/// Protocol used to extend an `HTTPDataClient` with support for
/// automatic encoding and decoding or request and response data.
public protocol HTTPCodable {
    var jsonEncoder: JSONEncoder { get set }
    var jsonDecoder: JSONDecoder { get set }
}

public extension HTTPCodable where Self: HTTPClient {
    fileprivate func encode<E: Encodable>(_ encodable: E?) throws -> Data? {
        var data: Data? = nil
        if let encodable = encodable {
            data = try jsonEncoder.encode(encodable)
        }
        return data
    }
    
    fileprivate func decode<D: Decodable>(statusCode: Int, headers: HTTP.Headers?, data: Data?, error: Swift.Error?, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        guard let data = data else {
            completion(statusCode, headers, nil, error)
            return
        }
        
        let result: D
        do {
            result = try jsonDecoder.decode(D.self, from: data)
            completion(statusCode, headers, result, nil)
        } catch let decoderError {
            completion(statusCode, headers, nil, decoderError)
        }
    }
    
    public func get<D: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        self.get(path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    public func put<E: Encodable, D: Decodable>(_ encodable: E?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        var data: Data? = nil
        do {
            data = try self.encode(encodable)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        self.put(data, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    public func post<E: Encodable, D: Decodable>(_ encodable: E?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        var data: Data? = nil
        do {
            data = try self.encode(encodable)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        self.post(data, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    public func post<D: Decodable>(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        self.post(data, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    public func patch<E: Encodable, D: Decodable>(_ encodable: E?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        var data: Data? = nil
        do {
            data = try self.encode(encodable)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        self.patch(data, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    public func delete<D: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        self.delete(path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
}
