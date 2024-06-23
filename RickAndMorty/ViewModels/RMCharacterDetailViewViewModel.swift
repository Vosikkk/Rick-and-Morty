//
//  RMCharacterDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 23.06.2024.
//

import Foundation


final class RMCharacterDetailViewViewModel {
    
    private let character: RMCharacter
    
    init(character: RMCharacter) {
        self.character = character
    }
    
    public var title: String {
        character.name.uppercased()
    }
}
