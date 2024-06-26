//
//  RMGetEpisodesResponse.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 27.06.2024.
//

import Foundation



struct RMGetEpisodesResponse: Decodable {
    
    struct Info: Decodable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }
    
    let info: Info
    let results: [RMEpisode]
    
}
    
