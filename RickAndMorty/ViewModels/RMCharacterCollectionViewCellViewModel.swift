//
//  RMCharacterCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import Foundation


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
        let request = URLRequest(url: characterImageUrl)
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data, error == nil else {
                completion(.failure(error ?? URLError.init(.badServerResponse)))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}



extension RMCharacterCollectionViewCellViewModel {
    
    public func fetchImageAsync() async throws -> Data {
        guard let characterImageUrl else {
            throw URLError.init(.badURL)
        }
        guard let (data, _) = try? await URLSession.shared.data(from: characterImageUrl) else {
            throw URLError.init(.badServerResponse)
        }
        return data
    }
}
