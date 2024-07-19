//
//  RMLoactionDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 01.07.2024.
//

import Foundation

protocol RMLocationDetailViewViewModelDelegate: AnyObject {
    func didFetchLocationDetails()
}

public enum SectionType {
    case information(vm: [RMEpisodeInfoCollectionViewCellViewModel])
    case characters(vm: [RMCharacterCollectionViewCellViewModel])
}

final class RMLoactionDetailViewViewModel: DetailViewModel {
    
    typealias DataInfo = (data: RMLocation, characters: [RMCharacter])
    
    private let dateFormatter: FormatterOfDate = .init()
    
    private(set) var service: Service
    
    private(set) var endpointUrl: URL?
    
    public weak var delegate: RMLocationDetailViewViewModelDelegate?
    
   
    private(set) var data: DataInfo? {
        didSet {
            createCellViewModels()
            delegate?.didFetchLocationDetails()
        }
    }
    
    public private(set) var cellViewModels: [SectionType] = []
    
    
    init(endpointUrl: URL?, service: Service) {
        self.service = service
        self.endpointUrl = endpointUrl
    }
    
    
    func createCellViewModels() {
        guard let data else { return }
        let location = data.data
        let characters = data.characters
        let createdString = dateFormatter.createShortDate(from: location.created)
        cellViewModels = [
            .information(vm: [
                .init(title: "Location Name", value: location.name),
                .init(title: "Type", value: location.type),
                .init(title: "Dimension", value: location.dimension),
                .init(title: "Created", value: createdString),
            ]),
            .characters(vm:
                characters.compactMap {
                    return RMCharacterCollectionViewCellViewModel(
                        characterName: $0.name,
                        characterStatus: $0.status,
                        characterImageUrl: URL(string: $0.image),
                        service: service
                    )
                }
            )
        ]
    }
    
    public func fetchData() {
        guard let endpointUrl,
                let request = RMRequest(url: endpointUrl) else {
            return
        }
        service.execute(request, expecting: RMLocation.self) { [weak self] res in
            switch res {
            case .success(let model):
                self?.fetchRelatedItems(for: model)
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    
    
    func fetchRelatedItems(for data: RMLocation) {
        let requests: [RMRequest] = data.residents
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
