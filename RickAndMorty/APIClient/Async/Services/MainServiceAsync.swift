//
//  MainServiceAsync.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 05.07.2024.
//

import Foundation

final class MainServiceAsync {
    
    private let character: CharacterService
    private let episode: EpisodesService
    private let location: LocationService
    
    
    init(character: CharacterService, episode: EpisodesService, location: LocationService) {
        self.character = character
        self.episode = episode
        self.location = location
    }
    
    public func fetchCharacter(for request: RMRequest) async throws -> RMGetCharactersResponse {
        return try await character.execute(request)
    }
    
    public func fetchLocation(for request: RMRequest) async throws -> RMGetLocationsResponse {
        return try await location.execute(request)
    }
   
    public func fetchEpisode(for request: RMRequest) async throws -> RMGetEpisodesResponse {
        return try await episode.execute(request)
    }
}

