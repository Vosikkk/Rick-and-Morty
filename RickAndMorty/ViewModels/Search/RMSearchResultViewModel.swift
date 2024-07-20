//
//  RMSearchResultViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 10.07.2024.
//

import Foundation


final class RMSearchResultViewModel {
    
    private(set) var data: [any Hashable]
    private(set) var nextUrl: String?
    private var calculator: CalculatorIndexPaths
    
    private let service: Service
    
    
    public private(set) var isLoadingMoreResults: Bool = false {
        didSet {
            if isLoadingMoreResults,
                calculator._lastIndex != data.endIndex {
                calculator._lastIndex = data.endIndex
            }
        }
    }
    
    public var shouldShowLoadIndicator: Bool {
        nextUrl != nil
    }
    
    
    convenience init(
        resultType: RMSearchResultType,
        and nextUrl: String?,
        service: Service
    ) {
        var data: [any Hashable]
        switch resultType {
        case .characters(let existingData):
            data = existingData
        case .locations(let existingData):
            data = existingData
        case  .episodes(let existingData):
            data = existingData
        }
        self.init(
            nextUrl: nextUrl,
            existingData: data,
            service: service
        )
    }
    
    init(
        nextUrl: String?,
        existingData: [any Hashable],
        service: Service
    ) {
        self.nextUrl = nextUrl
        self.data = existingData
        self.service = service
        calculator = .init(lastIndex: data.endIndex)
    }
    
    
    public func fetchAdditionalResults(
        completion: @escaping ([IndexPath]) -> Void
    ) {
        guard !isLoadingMoreResults,
              let nextURLString = nextUrl,
              let url = URL(string: nextURLString) else {
            return
        }
        
        isLoadingMoreResults = true
        
        guard let request = RMRequest(url: url) else {
            isLoadingMoreResults = false
            return
        }
        
         if let firstElement = data.first,
            let fetchHandler = getFetchHandler(for: firstElement) {
            fetchHandler(request, completion)
         } else {
             isLoadingMoreResults = false
         }
    }
    
    
    private func getFetchHandler<T: Hashable>(
        for element: T
    ) -> ((RMRequest, @escaping ([IndexPath]) -> Void) -> Void)? {
        
        switch element {
        case is RMCharacterCollectionViewCellViewModel:
            return { [weak self] request, completion in
                guard let self else { return }
                fetchResults(
                    for: request,
                    expecting: RMGetCharactersResponse.self,
                    map: { self.mapCharactersVMs(from: $0) },
                    completion: completion
                )
            }
        case is RMLocationTableViewCellViewModel:
            return { [weak self] request, completion in
                guard let self else { return }
                fetchResults(
                    for: request,
                    expecting: RMGetLocationsResponse.self,
                    map: { self.mapLocationsVms(from: $0) },
                    completion: completion
                )
            }

        case is RMCharacterEpisodeCollectionViewCellViewModel:
            return { [weak self] request, completion in
                guard let self else { return }
                fetchResults(
                    for: request,
                    expecting: RMGetEpisodesResponse.self,
                    map: { self.mapEpisodesVms(from: $0) },
                    completion: completion
                )
            }
        default:
            return nil
        }
    }
    
    
    private func fetchResults<T: ResponseModel>(
        for request: RMRequest,
        expecting: T.Type,
        map: @escaping (T.ResultResponse) -> [any Hashable],
        completion: @escaping ([IndexPath]) -> Void
    ) {
        service.execute(request, expecting: T.self) { [weak self] result in
            switch result {
            case .success(let respModel):
                self?.update(
                    nextUrl: respModel.info.next,
                    data: map(respModel.results),
                    completion: completion
                )
            case .failure(let failure):
                self?.isLoadingMoreResults = false
                print(failure)
            }
        }
    }
  

    private func update(
        nextUrl: String?,
        data: [any Hashable],
        completion: @escaping ([IndexPath]) -> Void
    ) {
        self.nextUrl = nextUrl
        self.data.append(contentsOf: data)
        DispatchQueue.mainAsyncIfNeeded { [weak self] in
            guard let self else { return }
            isLoadingMoreResults = false
            completion(calculator.calculateIndexPaths(count: data.count))
        }
    }
    
    private func mapCharactersVMs(
        from elements: [RMCharacter]
    ) -> [RMCharacterCollectionViewCellViewModel] {
        elements.compactMap {
            .init(
                characterName: $0.name,
                characterStatus: $0.status,
                characterImageUrl: URL(string: $0.image),
                service: service
            )
        }
    }
    
    private func mapEpisodesVms(
        from elements: [RMEpisode]
    ) -> [RMCharacterEpisodeCollectionViewCellViewModel] {
        elements.compactMap {
            .init(
                episodeDataURL: URL(string:$0.url),
                service: service
            )
        }
    }
    
    private func mapLocationsVms(
        from elements: [RMLocation]
    ) -> [RMLocationTableViewCellViewModel] {
        elements.compactMap {
            .init(location: $0)
        }
    }
}
