//
//  RMCharacterEpisodeCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 25.06.2024.
//

import Foundation

protocol EpisodeDataRender {
    var name: String { get }
    var air_date: String { get }
    var episode: String { get }
}


final class RMCharacterEpisodeCollectionViewCellViewModel {
    
    private let episodeDataURL: URL?
    
    private var isFetching: Bool = false
    
    private var dataBlock: ((EpisodeDataRender) -> Void)?
    
    private var episode: RMEpisode? {
        didSet {
            guard let model = episode else {
                return
            }
            dataBlock?(model)
        }
    }
    
    // MARK: - Init
    
    init(episodeDataURL: URL?) {
        self.episodeDataURL = episodeDataURL
    }
    
    
    public func registerForData(_ block: @escaping (EpisodeDataRender) -> Void) {
        self.dataBlock = block
    }
    
    public func fetchEpisode() {
        guard !isFetching,
              let episodeDataURL,
              let request = RMRequest(url: episodeDataURL) else {
            if let model = episode {
                dataBlock?(model)
            }
            return
        }
        isFetching = true
        RMService().execute(request, expecting: RMEpisode.self) { [weak self] res in
            switch res {
            case .success(let model):
                DispatchQueue.main.async {
                    self?.episode = model
                }
            case .failure(_):
                break
            }
        }
    }
}
