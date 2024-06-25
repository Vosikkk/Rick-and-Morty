//
//  RMCharacterDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 23.06.2024.
//

import Foundation


final class RMCharacterDetailViewViewModel {
    
    private let character: RMCharacter
    
    
    enum SectionType: CaseIterable {
        case photo, information, episodes
    }
    
    public let sections: SectionType.AllCases = SectionType.allCases
    
    
    // MARK: - Init 
    init(character: RMCharacter) {
        self.character = character
    }
    
    private var requestUrl: URL? {
        URL(string: character.url)
    }
    
    public var title: String {
        character.name.uppercased()
    }
}
