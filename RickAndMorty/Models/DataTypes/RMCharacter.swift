//
//  RMCharacter.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation

struct RMCharacter: Codable {
    
    let id: Int
    let name: String
    let status: RMCharacterStatus
    let species: String
    let type: String
    let gender: RMCharacterGender
    let origin: RMOrigin
    let location: RMLocation
    let image: String
    let episode: [String]
    let url: String
    let created: String
    
    
    enum RMCharacterGender: String, Codable {
        case female = "Female"
        case male = "Male"
        case genderless = "Genderless"
        case`unknown` = "unknown"
    }
    
    enum RMCharacterStatus: String, Codable {
        case alive = "Alive"
        case dead = "Dead"
        case `unknown` = "unknown"
    }
    
    struct RMOrigin: Codable {
        let name: String
        let url: String
    }

    struct RMLocation: Codable {
        let name: String
        let url: String
    }
}
