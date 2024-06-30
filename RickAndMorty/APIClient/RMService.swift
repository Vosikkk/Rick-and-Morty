//
//  RMService.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation


/// Primary API service object to get Rick and Morty data
final class RMService: Service {

    private let cache: RMAPICacheManager = RMAPICacheManager()
    
    
    /// Send Rick and Morty API call
    /// - Parameters:
    ///   - request: Instance of Request opaque types
    ///   - type: The type of object we expect to getback
    ///   - completion: Call back with data or error
    func execute<T: JsonModel>(
        _ request: some Request,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void) {
            
            guard let rmRequest = request as? RMRequest else {
                completion(.failure(RMServiceError.invalidRequestType))
                return
            }
            
            if let cachedData = cache.cachedResponse(
                for: rmRequest.endpoint,
                url: rmRequest.url
            ) {
                print("Using Cached Api Response")
                do {
                    let res = try T.init(json: cachedData)
                    completion(.success(res))
                } catch {
                    completion(.failure(error))
                }
                return
            }
            
            guard let urlRequest = self.request(from: rmRequest) else {
                completion(.failure(RMServiceError.failedToCreateRequest))
                return
            }
            
            let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(error ?? RMServiceError.failedToGetData))
                    return
                }
                
                do {
                    let res = try T.init(json: data)
                    self?.cache.setCache(
                        for: rmRequest.endpoint,
                        url: rmRequest.url,
                        data: data
                    )
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
    case invalidRequestType
}

