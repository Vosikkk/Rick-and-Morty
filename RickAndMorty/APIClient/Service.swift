//
//  Service.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import Foundation

///  Each who wants work with client have to implment the protocol
public protocol Service {
    func execute<T: Codable>(
        _ request: some Request,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void)
}

extension Service {
   
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
    
    func request(from rmRequest: some Request) -> URLRequest? {
        guard let url = rmRequest.url,
              let rm = rmRequest as? RMRequest else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = rm.httpMethod
        return request
    }
}
