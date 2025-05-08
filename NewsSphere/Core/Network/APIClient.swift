//
//  APIClient.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 5/3/25.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private init() {}
    
    func request<T: Decodable>(endpoint: APIEndpoint,
                               responseType: T.Type,
                               completion: @escaping (Result<T, NetworkError>) -> Void) {
        var request = URLRequest(url: endpoint.fullUrl)
        request.httpMethod = endpoint.method.rawValue
        
        print(endpoint.fullUrl)
        
        // Add headers
        for (key, value) in endpoint.headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Add body for POST/PUT requests
        if endpoint.method == .post || endpoint.method == .put {
            if !endpoint.params.isEmpty {
                do {
                    request.httpBody = try JSONSerialization
                        .data(withJSONObject: endpoint.params, options: [])
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    completion(.failure(.encodingError))
                    return
                }
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidStatusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedObject = try decoder.decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
}
