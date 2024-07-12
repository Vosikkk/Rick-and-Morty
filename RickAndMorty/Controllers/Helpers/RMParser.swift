//
//  RMParser.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 12.07.2024.
//

import Foundation

protocol RMParser {
    
    typealias Response = (
        vms: [any Hashable],
        nextUrl: String?
    )

    func parseCharacters(
        from response: any JsonModel
    ) throws -> Response
    
    func parseLocations(
        from response: any JsonModel
    ) throws -> Response
   
    func parseEpisodes(
        from response: any JsonModel
    ) throws -> Response
}

struct RMResponseParser: RMParser {
    
    private let service: Service
    
    init(service: Service = RMService()) {
        self.service = service
    }
    
    func parseCharacters(from response: any JsonModel) throws -> Response {
        
        guard let resp = response as? RMGetCharactersResponse else {
            throw CastError.cannotCastCharacters
        }
         let vms = resp.results
            .compactMap {
                RMCharacterCollectionViewCellViewModel(
                    characterName: $0.name,
                    characterStatus: $0.status,
                    characterImageUrl: URL(string: $0.image)
                )
            }
        return (vms, resp.info.next)
    }
    
    func parseLocations(from response: any JsonModel) throws -> Response {
        guard let resp = response as? RMGetLocationsResponse else {
            throw CastError.cannotCastLocations
        }
         let vms = resp.results
            .compactMap {
                RMLocationTableViewCellViewModel(location: $0)
            }
        return (vms, resp.info.next)
    }
    
    
    
    func parseEpisodes(from response: any JsonModel) throws -> Response {
        guard let resp = response as? RMGetEpisodesResponse else {
            throw CastError.cannotCastEpisodes
        }
         let vms = resp.results
            .compactMap {
                RMCharacterEpisodeCollectionViewCellViewModel(
                    episodeDataURL: URL(string: $0.url),
                    service: self.service
                )
            }
        return (vms, resp.info.next)
    }
}
