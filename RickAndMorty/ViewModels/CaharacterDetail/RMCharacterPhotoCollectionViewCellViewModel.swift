//
//  RMCharacterPhotoCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 25.06.2024.
//

import Foundation

final class RMCharacterPhotoCollectionViewCellViewModel {
    
    typealias Completion = (Result<Data, Error>) -> Void
    
    private let imageURL: URL?
    
    private let service: Service
    
    init(imageURL: URL?, service: Service) {
        self.imageURL = imageURL
        self.service = service
    }
    
    public func fetchImage(completion: @escaping Completion) {
        guard let imageURL else {
            completion(.failure(URLError(.badURL)))
            return
        }
        service.imageLoader.downloadImage(imageURL, completion: completion)
    }
}
