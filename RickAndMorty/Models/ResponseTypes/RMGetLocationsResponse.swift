//
//  RMGetLocationsResponse.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 30.06.2024.
//

import Foundation

struct RMGetLocationsResponse {
    let info: Info
    let results: [RMLocation]
}

extension RMGetLocationsResponse: ResponseModel {
    init(json: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: json)
    }
}
    
