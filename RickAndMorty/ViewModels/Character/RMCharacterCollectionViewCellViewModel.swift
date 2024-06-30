//
//  RMCharacterCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import Foundation
import UIKit

final class RMCharacterCollectionViewCellViewModel {
    
    
    typealias ChrStatus = RMCharacter.RMCharacterStatus
    
    public let characterName: String
    private let characterStatus: ChrStatus
    private let characterImageUrl: URL?
    
    
    
    // MARK: - Init
    init(
        characterName: String,
        characterStatus: ChrStatus,
        characterImageUrl: URL?
    ) {
        self.characterName = characterName
        self.characterStatus = characterStatus
        self.characterImageUrl = characterImageUrl
    }
    
    
    public var characterStatusText: String {
        "Status: \(characterStatus.text)"
    }
    
    public func fetchImage(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let characterImageUrl else {
            completion(.failure(URLError.init(.badURL)))
            return
        }
        RMImageLoader.shared.downloadImage(characterImageUrl, completion: completion)
    }
}





// MARK: - Hashable

extension RMCharacterCollectionViewCellViewModel: Hashable {
    
    static func == (
        lhs: RMCharacterCollectionViewCellViewModel,
        rhs: RMCharacterCollectionViewCellViewModel
    ) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
     
    func hash(into hasher: inout Hasher) {
        hasher.combine(characterName)
        hasher.combine(characterStatus)
        hasher.combine(characterImageUrl)
    }
}
