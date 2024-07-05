//
//  CharacterService.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 05.07.2024.
//

import Foundation

final class CharacterService: AsyncService {
   
    private let cache: RMAPICacheActor
    
    
    init(cache: RMAPICacheActor) {
        self.cache = cache
    }

    func execute(_ request: some Request) async throws -> RMGetCharactersResponse {
        
        guard let rmRequest = request as? RMRequest else {
            throw RMServiceError.invalidRequestType
        }
        
        if let cachedData = await cache.cachedResponse(
            for: rmRequest.endpoint,
            url: rmRequest.url) {
            print("Cache")
            return try RMGetCharactersResponse(json: cachedData)
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
        
        async let res = try RMGetCharactersResponse(json: data)
        
        let finished = try await (save, res)
        
        return finished.1
    }
}
