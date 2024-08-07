//
//  RMGetCharactersResponse.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import Foundation

struct RMGetCharactersResponse {
    let info: Info
    let results: [RMCharacter]
}

extension RMGetCharactersResponse: ResponseModel {
    init(json: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: json)
    }
}

