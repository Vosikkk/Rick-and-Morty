//
//  Mapper.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.07.2024.
//

import Foundation

protocol Map {
    associatedtype ViewModel: Hashable
    associatedtype JsModel: JsonModel
    func map(from elements: [JsModel]) -> [ViewModel]
}

struct CharacterMapper: Map {
    
    let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    public func map(
        from elements: [RMCharacter]
    ) -> [RMCharacterCollectionViewCellViewModel] {
        
        return elements.compactMap {
            RMCharacterCollectionViewCellViewModel(
                characterName: $0.name,
                characterStatus: $0.status,
                characterImageUrl: URL(string: $0.image),
                service: service
            )
        }
    }
}

struct LocationMapper: Map {
    
    func map(
        from elements: [RMLocation]
    ) -> [RMLocationTableViewCellViewModel] {
        return elements.compactMap {
            RMLocationTableViewCellViewModel(location: $0)
        }
    }
}

struct EpisodeMapper: Map {
    
    let service: Service
    
    func map(
        from elements: [RMEpisode]
    ) -> [RMCharacterEpisodeCollectionViewCellViewModel] {
       
        return elements.compactMap {
            RMCharacterEpisodeCollectionViewCellViewModel(
                episodeDataURL: URL(string: $0.url),
                service: service
            )
        }
    }
}
