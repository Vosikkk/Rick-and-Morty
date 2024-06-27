//
//  RMEpisodeDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 27.06.2024.
//

import Foundation

protocol RMEpisodeDetailViewViewModelDelegate: AnyObject {
    func didFetchEpisodeDetails()
}


final class RMEpisodeDetailViewViewModel {
    
    typealias EpisodeInfo = (episode: RMEpisode, characters: [RMCharacter])
    
    public weak var delegate: RMEpisodeDetailViewViewModelDelegate?
    
    private let endpointUrl: URL?
    private let service: Service
    
    private var data: EpisodeInfo? {
        didSet {
            createCellViewModels()
            delegate?.didFetchEpisodeDetails()
        }
    }
    
    enum SectionType {
        case information(vm: [RMEpisodeInfoCollectionViewCellViewModel])
        case characters(vm: [RMCharacterCollectionViewCellViewModel])
    }
    
    public private(set) var cellViewModels: [SectionType] = []
    
    // MARK: - Init
    
    init(endpointUrl: URL?, service: Service) {
        self.service = service
        self.endpointUrl = endpointUrl
    }
    
    /// Fetch backing episode model
    public func fetchEpisodeData() {
        guard let endpointUrl,
                let request = RMRequest(url: endpointUrl) else {
            return
        }
        service.execute(request, expecting: RMEpisode.self) { [weak self] res in
            switch res {
            case .success(let model):
                self?.fetchRelatedCharacters(for: model)
            case .failure(_):
                break
            }
        }
    }
    
    private func createCellViewModels() {
        guard let data else { return }
        let episode = data.episode
        let characters = data.characters
        
        cellViewModels = [
            .information(vm: [
                .init(title: "Episode Name", value: episode.name),
                .init(title: "Air Date", value: episode.air_date),
                .init(title: "Episode", value: episode.episode),
                .init(title: "Created", value: episode.created)
            ]),
            .characters(vm: characters.compactMap {
                                return RMCharacterCollectionViewCellViewModel(
                                    characterName: $0.name,
                                    characterStatus: $0.status,
                                    characterImageUrl: URL(string: $0.image)
                                )
                            }
                       )
        ]
    }
    
    private func fetchRelatedCharacters(for episode: RMEpisode) {
        let requests: [RMRequest] = episode.characters
            .compactMap {  URL(string: $0) }
            .compactMap { RMRequest(url: $0) }
        let group = DispatchGroup()
        var characters: [RMCharacter] = []
        for request in requests {
            group.enter()
            service.execute(request, expecting: RMCharacter.self) { res in
                defer { group.leave() }
                switch res {
                case .success(let model):
                    characters.append(model)
                case .failure:
                    break
                }
            }
        }
        
        group.notify(queue: .main) {
            self.data = (episode: episode, characters: characters)
        }
    }
}



extension RMEpisodeDetailViewViewModel {
    
    actor SyncHelper<T: Decodable> {
        var data: [T] = []
        func add(_ element: T) {
            data.append(element)
        }
    }
    
    // MARK: - Async approach
    
    private func fetch(episode: RMEpisode, requests: [RMRequest]) async throws {
        
        let helper = SyncHelper<RMCharacter>()
        
        try await withThrowingTaskGroup(of: Void.self) { [weak self] group in
            guard let self else { return }
            
            for request in requests {
                group.addTask {
                    await helper.add(try await self.getCharacter(from: request))
                }
            }
            try await group.waitForAll()
        }
        
        let characters = await helper.data
        
        await MainActor.run {
            self.data = (episode, characters)
        }
    }
    
    private func getCharacter(from request: RMRequest) async throws -> RMCharacter {
        try await withCheckedThrowingContinuation { сontinuation  in
            self.service.execute(request, expecting: RMCharacter.self) { res in
                switch res {
                case .success(let model):
                    сontinuation.resume(returning: model)
                case .failure(let error):
                    сontinuation.resume(throwing: error)
                }
            }
        }
    }
}
