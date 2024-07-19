//
//  RMCharacterCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import Foundation
import UIKit

public final class RMCharacterCollectionViewCellViewModel {
    
    
    typealias ChrStatus = RMCharacter.RMCharacterStatus
    
    public let characterName: String
    private let characterStatus: ChrStatus
    private let characterImageUrl: URL?
    private let service: Service
    
    
    // MARK: - Init
    
    init(
        characterName: String,
        characterStatus: ChrStatus,
        characterImageUrl: URL?,
        service: Service
    ) {
        self.characterName = characterName
        self.characterStatus = characterStatus
        self.characterImageUrl = characterImageUrl
        self.service = service
    }
    
    
    public var characterStatusText: String {
        "Status: \(characterStatus.text)"
    }
    
    public func fetchImage(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let characterImageUrl else {
            completion(.failure(URLError.init(.badURL)))
            return
        }
        service.imageLoader.downloadImage(characterImageUrl, completion: completion)
    }
}





// MARK: - Hashable

extension RMCharacterCollectionViewCellViewModel: Hashable {
    
    public static func == (
        lhs: RMCharacterCollectionViewCellViewModel,
        rhs: RMCharacterCollectionViewCellViewModel
    ) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
     
   public func hash(into hasher: inout Hasher) {
        hasher.combine(characterName)
        hasher.combine(characterStatus)
        hasher.combine(characterImageUrl)
    }
}
