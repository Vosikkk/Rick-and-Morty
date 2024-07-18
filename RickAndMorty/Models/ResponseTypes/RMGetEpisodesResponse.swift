//
//  RMGetEpisodesResponse.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 27.06.2024.
//

import Foundation



struct RMGetEpisodesResponse {
    let info: Info
    let results: [RMEpisode]
}

extension RMGetEpisodesResponse: ResponseModel {
    init(json: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: json)
    }
}
