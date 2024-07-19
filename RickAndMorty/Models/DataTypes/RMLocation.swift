//
//  RMLocation.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation


struct RMLocation {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [String]
    let url: String
    let created: String
}

extension RMLocation: JsonModel {
    init(json: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: json)
    }
}
