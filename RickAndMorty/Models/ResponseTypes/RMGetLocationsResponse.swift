//
//  RMGetLocationsResponse.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 30.06.2024.
//

import Foundation

public protocol JsonModel: Decodable {
    init(json: Data) throws
}


struct RMGetLocationsResponse {
    
    struct Info: Decodable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }
    
    let info: Info
    let results: [RMLocation]
    
}

extension RMGetLocationsResponse: JsonModel {
    init(json: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: json)
    }
}
    
