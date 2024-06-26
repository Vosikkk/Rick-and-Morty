//
//  RMGetEpisodesResponse.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 27.06.2024.
//

import Foundation



struct RMGetEpisodesResponse {
    
    struct Info: Decodable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }
    
    let info: Info
    let results: [RMEpisode]
}

extension RMGetEpisodesResponse: JsonModel {
    init(json: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: json)
    }
}
