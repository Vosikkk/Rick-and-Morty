//
//  RMService.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation


/// Primary API service object to get Rick and Morty data
final class RMService: Service {

    private let cache: RMAPICacheManager
    
    let imageLoader: RMImageLoader
    
    
    init(cache: RMAPICacheManager, imageLoader: RMImageLoader) {
        self.imageLoader = imageLoader
        self.cache = cache
    }
    
    
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
                decode(cachedData, completion: completion)
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
                
                self?.cache.setCache(
                    for: rmRequest.endpoint,
                    url: rmRequest.url,
                    data: data
                )
                self?.decode(data, completion: completion)
            }
            task.resume()
        }
    
    private func decode<T: JsonModel>(_ data: Data, completion: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let res = try T.init(json: data)
                DispatchQueue.mainAsyncIfNeeded {
                    completion(.success(res))
                }
            } catch {
                DispatchQueue.mainAsyncIfNeeded {
                    completion(.failure(error))
                }
            }
        }
    }
}

enum RMServiceError: Error {
    case failedToCreateRequest
    case failedToGetData
    case failedDecodeData
    case invalidRequestType
}

