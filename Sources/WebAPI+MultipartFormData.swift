import Foundation

public extension WebAPI {
    /// Transforms the request into a `multipart/form-data` request.
    /// The request `content-type` will be set to `image/png`
    public func execute(method: HTTP.RequestMethod, path: String, queryItems: [URLQueryItem]?, pngImageData: Data, filename: String = "image.png", completion: @escaping HTTP.DataTaskCompletion) {
        var request: URLRequest
        do {
            request = try self.request(method: method, path: path, queryItems: queryItems, data: nil)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        let boundary = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: HTTP.Header.contentType.rawValue)
        
        var data = Data()
        
        if let d = "--\(boundary)\r\n".data(using: String.Encoding.utf8) {
            data.append(d)
        }
        if let d = "Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8) {
            data.append(d)
        }
        if let d = "Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8) {
            data.append(d)
        }
        data.append(pngImageData)
        if let d = "\r\n".data(using: String.Encoding.utf8) {
            data.append(d)
        }
        if let d = "--\(boundary)--\r\n".data(using: String.Encoding.utf8) {
            data.append(d)
        }
        
        let contentLength = String(format: "%zu", data.count)
        request.setValue(contentLength, forHTTPHeaderField: HTTP.Header.contentLength.rawValue)
        
        request.httpBody = data
        
        self.execute(request: request, completion: completion)
    }
}
