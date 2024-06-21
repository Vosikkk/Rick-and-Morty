//
//  RMService.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation


///  Each who wants work with client have to implment the protocol
protocol Service {
    func execute<T: Codable>(
        _ request: some Request,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void)
   
    func execute<T: Codable>(
        _ request: some Request,
        expecting type: T.Type
    ) async throws -> T
}


/// Primary API service object to get Rick and Morty data
final class RMService: Service {
  
    
    /// Send Rick and Morty API call
    /// - Parameters:
    ///   - request: Instance of Request opaque types
    ///   - type: The type of object we expect to getback
    ///   - completion: Call back with data or error
    func execute<T: Codable>(
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
    
    
    /// /// Send Rick and Morty API call async
    ///  - Parameter request: Instance of Request opaque types
    ///  - Parameter type: The type of object we expect to getback
    func execute<T: Codable>(
        _ request: some Request,
        expecting type: T.Type)
    async throws -> T {
        guard let urlRequest = self.request(from: request) else {
            throw RMServiceError.failedToCreateRequest
        }
        
        guard let (data, _) = try? await URLSession.shared.data(for: urlRequest) else {
            throw RMServiceError.failedToGetData
        }
        
        guard let res = try? JSONDecoder().decode(type.self, from: data) else {
            throw RMServiceError.failedDecodeData
        }
        return res
    }
    
    private func request(from rmRequest: some Request) -> URLRequest? {
        guard let url = rmRequest.url,
              let rm = rmRequest as? RMRequest else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = rm.httpMethod
        return request
    }
    
    
    enum RMServiceError: Error {
        case failedToCreateRequest 
        case failedToGetData
        case failedDecodeData
    }
}

