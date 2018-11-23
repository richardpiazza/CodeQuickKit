import Foundation

/// The essential components of a HTTP/REST/JSON Client.
/// This protocol provides a lightweight wrapper around Foundations URLSeesion
/// for interacting with JSON REST API's.
public protocol HTTPClient {
    
    /// The root URL used to construct all queries.
    var baseURL: URL { get }
    
    /// The `URLSession` used to create tasks.
    var session: URLSession { get set }
    
    /// Auth credentials to provide in the request headers.
    var authorization: HTTP.Authorization? { get set }
    
    
    /// Constructs the request, setting the method, body data, and headers
    /// based on parameters specified.
    func request(method: HTTP.RequestMethod, path: String, queryItems: [URLQueryItem]?, data: Data?) throws -> URLRequest
    
    /// Creates a URLSessionDataTask using the URLSession.
    /// Allows access to the unstarted task, usefull for background execution.
    func task(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion) throws -> URLSessionDataTask
    
    /// Executes the specified request.
    /// Gets the task from `task(request:_,completion:_)` and calls `.resume()`.
    func execute(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion)
}

public extension HTTPClient {
    public func request(method: HTTP.RequestMethod, path: String, queryItems: [URLQueryItem]?, data: Data?) throws -> URLRequest {
        let pathURL = baseURL.appendingPathComponent(path)
        
        var urlComponents = URLComponents(url: pathURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw HTTP.Error.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let data = data {
            request.httpBody = data
            request.setValue("\(data.count)", forHTTPHeader: HTTP.Header.contentLength)
        }
        request.setValue(HTTP.Header.dateFormatter.string(from: Date()), forHTTPHeader: HTTP.Header.date)
        request.setValue(HTTP.MIMEType.applicationJson.rawValue, forHTTPHeader: HTTP.Header.accept)
        request.setValue(HTTP.MIMEType.applicationJson.rawValue, forHTTPHeader: HTTP.Header.contentType)
        
        if let authorization = self.authorization {
            request.setValue(authorization.headerValue, forHTTPHeader: HTTP.Header.authorization)
        }
        
        return request
    }
    
    public func task(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion) throws -> URLSessionDataTask {
        guard request.url != nil else {
            throw HTTP.Error.invalidURL
        }
        
        return session.dataTask(with: request) { (responseData, urlResponse, error) in
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                completion(0, nil, responseData, error ?? HTTP.Error.invalidResponse)
                return
            }
            
            completion(httpResponse.statusCode, httpResponse.allHeaderFields, responseData, error)
        }
    }
    
    public func execute(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion) {
        let task: URLSessionDataTask
        do {
            task = try self.task(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        task.resume()
    }
}

public extension HTTPClient {
    /// Convenience method for generating and executing a request using the `GET` http method.
    public func get(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.DataTaskCompletion) {
        do {
            let request = try self.request(method: .get, path: path, queryItems: queryItems, data: nil)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    /// Convenience method for generating and executing a request using the `PUT` http method.
    public func put(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.DataTaskCompletion) {
        do {
            let request = try self.request(method: .put, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    /// Convenience method for generating and executing a request using the `POST` http method.
    public func post(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.DataTaskCompletion) {
        do {
            let request = try self.request(method: .post, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    /// Convenience method for generating and executing a request using the `PATCH` http method.
    public func patch(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.DataTaskCompletion) {
        do {
            let request = try self.request(method: .patch, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    /// Convenience method for generating and executing a request using the `DELETE` http method.
    public func delete(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.DataTaskCompletion) {
        do {
            let request = try self.request(method: .delete, path: path, queryItems: queryItems, data: nil)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
}
