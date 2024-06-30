//
//  LocationService.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 30.06.2024.
//

import Foundation


final class ServiceAsync<T: JsonModel>: AsyncService {
   
    private let cache: RMAPICacheActor = RMAPICacheActor()

    func execute(_ request: some Request) async throws -> any JsonModel {
        
        guard let rmRequest = request as? RMRequest else {
            throw RMServiceError.invalidRequestType
        }
        
        if let cachedData = await cache.cachedResponse(
            for: rmRequest.endpoint,
            url: rmRequest.url) {
            print("Cache")
            return try T(json: cachedData)
        }
        
        guard let urlRequest = self.request(from: request) else {
            throw RMServiceError.failedToCreateRequest
        }
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        async let save: Void = cache.setCache(
            for: rmRequest.endpoint,
            url: rmRequest.url,
            data: data
        )
        
        async let res = try T(json: data)
        
        await save
        
        return try await res
    }
}
