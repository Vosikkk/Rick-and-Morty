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
   
    private let dateFormatter: FormatterOfDate = .init()
    
    typealias EpisodeInfo = (data: RMEpisode, characters: [RMCharacter])
    
    public weak var delegate: RMEpisodeDetailViewViewModelDelegate?
    
    private(set) var endpointUrl: URL?
    private(set) var service: Service
    
    private(set) var data: EpisodeInfo? {
        didSet {
            createCellViewModels()
            delegate?.didFetchEpisodeDetails()
        }
    }
    
    public private(set) var cellViewModels: [SectionType] = []
    
    // MARK: - Init
    
    init(endpointUrl: URL?, service: Service) {
        self.service = service
        self.endpointUrl = endpointUrl
    }
    
    /// Fetch backing episode model
    public func fetchData() {
        guard let endpointUrl,
                let request = RMRequest(url: endpointUrl) else {
            return
        }
        service.execute(request, expecting: RMEpisode.self) { [weak self] res in
            switch res {
            case .success(let model):
                self?.fetchRelatedItems(for: model)
            case .failure(_):
                break
            }
        }
    }
    
    public func character(at index: Int) -> RMCharacter? {
        guard let data = data else { return nil }
        return data.characters[index]
    }
    
    func createCellViewModels() {
        guard let data else { return }
        let episode = data.data
        let characters = data.characters
        let createdString = dateFormatter.createShortDate(from: episode.created)
        let characterMapper = CharacterMapper(service: service)
        cellViewModels = [
            .information(vm: [
                .init(title: "Episode Name", value: episode.name),
                .init(title: "Air Date", value: episode.air_date),
                .init(title: "Episode", value: episode.episode),
                .init(title: "Created", value: createdString)
            ]),
            .characters(vm: characterMapper.map(from: characters))
        ]
    }
    
    
    func fetchRelatedItems(for data: RMEpisode) {
        let requests: [RMRequest] = data.characters
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
            self.data = (data: data, characters: characters)
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
