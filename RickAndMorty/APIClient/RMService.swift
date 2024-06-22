//
//  RMService.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation


/// Primary API service object to get Rick and Morty data
final class RMService: Service {

    /// Send Rick and Morty API call
    /// - Parameters:
    ///   - request: Instance of Request opaque types
    ///   - type: The type of object we expect to getback
    ///   - completion: Call back with data or error
    func execute<T: Decodable>(
        _ request: some Request,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void) {
            
            guard let urlRequest = self.request(from: request) else {
                completion(.failure(RMServiceError.failedToCreateRequest))
                return
            }
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(error ?? RMServiceError.failedToGetData))
                    return
                }
                
                do {
                    let res = try JSONDecoder().decode(type.self, from: data)
                    completion(.success(res))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
}

enum RMServiceError: Error {
    case failedToCreateRequest
    case failedToGetData
    case failedDecodeData
}
