//
//  RMCharacter.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation

struct RMCharacter: Decodable {
    
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
    
    
    enum RMCharacterGender: String, Decodable {
        case female = "Female"
        case male = "Male"
        case genderless = "Genderless"
        case`unknown` = "unknown"
    }
    
    enum RMCharacterStatus: String, Decodable {
        case alive = "Alive"
        case dead = "Dead"
        case `unknown` = "unknown"
        
        var text: String {
            switch self {
            case .alive, .dead:
                rawValue
            case .unknown:
                "Unknown"
            }
        }
    }
    
    struct RMOrigin: Decodable {
        let name: String
        let url: String
    }

    struct RMLocation: Decodable {
        let name: String
        let url: String
    }
}
