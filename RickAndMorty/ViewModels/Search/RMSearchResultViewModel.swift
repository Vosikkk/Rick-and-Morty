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
        
        guard let request = RMRequest(url: url), 
              let firstElement = data.first else {
            isLoadingMoreResults = false
            return
        }
        
        
        let fetchHandler = getFetchHandler(for: firstElement)
        fetchHandler?(request) { result in
            switch result {
            case .success(let indexPaths):
                completion(indexPaths)
            case .failure(let failure):
                print(failure)
                self.isLoadingMoreResults = false
            }
        }
    }
    
    
    private func getFetchHandler(
        for element: any Hashable
    ) -> ((RMRequest, @escaping (Result<[IndexPath], Error>) -> Void) -> Void)? {
        
        switch element {
        case is RMCharacterCollectionViewCellViewModel:
            return { [weak self] request, completion in
                guard let self else { return }
                fetchResults(
                    for: request,
                    expecting: RMGetCharactersResponse.self,
                    map: CharacterMapper(service: service).map,
                    completion: completion
                )
            }
        case is RMLocationTableViewCellViewModel:
            return { [weak self] request, completion in
                guard let self else { return }
                fetchResults(
                    for: request,
                    expecting: RMGetLocationsResponse.self,
                    map: LocationMapper().map,
                    completion: completion
                )
            }

        case is RMCharacterEpisodeCollectionViewCellViewModel:
            return { [weak self] request, completion in
                guard let self else { return }
                fetchResults(
                    for: request,
                    expecting: RMGetEpisodesResponse.self,
                    map: EpisodeMapper(service: service).map,
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
        completion: @escaping (Result<[IndexPath], Error>) -> Void
    ) {
        service.execute(request, expecting: T.self) { [weak self] result in
            switch result {
            case .success(let respModel):
                self?.update(
                    nextUrl: respModel.info.next,
                    data: map(respModel.results)) { indexPaths in
                        completion(.success(indexPaths))
                    }
            case .failure(let failure):
                self?.isLoadingMoreResults = false
                completion(.failure(failure))
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
}
