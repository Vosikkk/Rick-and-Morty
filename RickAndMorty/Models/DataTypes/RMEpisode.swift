//
//  RMEpisode.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation

struct RMEpisode: EpisodeDataRender {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
}

extension RMEpisode: JsonModel {
    init(json: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: json)
    }
}
