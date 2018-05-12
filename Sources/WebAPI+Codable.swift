import Foundation

public typealias CodableTaskCompletion<T: Codable> = (_ statusCode: Int, _ headers: HTTP.Headers?, _ data: T?, _ error: Error?) -> Void

public extension WebAPI {
    fileprivate func encode<T: Codable>(_ codable: T?) throws -> Data? {
        var codableData: Data? = nil
        if let codable = codable {
            codableData = try self.jsonEncoder.encode(codable)
        }
        return codableData
    }
    
    fileprivate func decode<T: Codable>(statusCode: Int, headers: HTTP.Headers?, data: Data?, error: Swift.Error?, completion: @escaping CodableTaskCompletion<T>) {
        guard error == nil else {
            completion(statusCode, headers, nil, error)
            return
        }
        
        guard let data = data else {
            completion(statusCode, headers, nil, error)
            return
        }
        
        let result: T
        do {
            result = try self.jsonDecoder.decode(T.self, from: data)
        } catch let decoderError {
            completion(statusCode, headers, nil, decoderError)
            return
        }
        
        completion(statusCode, headers, result, nil)
    }
    
    public func get<T: Codable>(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping CodableTaskCompletion<T>) {
        self.get(path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    public func put<T: Codable>(_ codable: T?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping CodableTaskCompletion<T>) {
        var codableData: Data? = nil
        do {
            codableData = try self.encode(codable)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        self.put(codableData, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    public func post<T: Codable>(_ codable: T?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping CodableTaskCompletion<T>) {
        var codableData: Data? = nil
        do {
            codableData = try self.encode(codable)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        self.post(codableData, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    public func patch<T: Codable>(_ codable: T?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping CodableTaskCompletion<T>) {
        var codableData: Data? = nil
        do {
            codableData = try self.encode(codable)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        self.patch(codableData, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    public func delete<T: Codable>(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping CodableTaskCompletion<T>) {
        self.delete(path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
}
