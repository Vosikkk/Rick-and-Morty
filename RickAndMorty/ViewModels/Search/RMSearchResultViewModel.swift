//
//  RMSearchResultViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 10.07.2024.
//

import Foundation

final class RMSearchResultViewModel {
    
    public private(set) var results: RMSearchResultType
    private var nextUrl: String?
    private let service: Service
    
    public var shouldShowLoadIndicator: Bool {
        nextUrl != nil 
    }
    
    public private(set) var isLoadingMoreResults: Bool = false
        
    
    init(with results: RMSearchResultType, 
         and nextUrl: String?,
         service: Service
    ) {
        self.results = results
        self.nextUrl = nextUrl
        self.service = service
    }
    
    
    public func fetchAdditionalResults(
        completion: @escaping ([any Hashable]) -> Void
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
        
        handleResults(request: request, completion: completion)
    }
    
    
    private func handleResults(
        request: RMRequest,
        completion: @escaping ([any Hashable]) -> Void
    ) {
        switch results {
        case .characters:
            service.execute(
                request,
                expecting: RMGetCharactersResponse.self
            ) { [weak self] res in
                
                self?.handleResponse(result: res, completion: completion)
            }
        case .locations:
            service.execute(
                request,
                expecting: RMGetLocationsResponse.self
            ) { [weak self] res in
               
                self?.handleResponse(result: res, completion: completion)
            }
        case .episodes:
            service.execute(
                request,
                expecting: RMGetEpisodesResponse.self
            ) { [weak self] res in
               
                self?.handleResponse(result: res, completion: completion)
            }
        }
    }
    
    private func handleResponse<T: JsonModel>(
        result: Result<T, Error>,
        completion: @escaping ([any Hashable]) -> Void
    ) {
        switch result {
        case .success(let responseModel):
             
            let newRes = parse(responseModel)
             
            updateResults(
                with: newRes.vms,
                nextUrl: newRes.nextUrl,
                completion: completion
             )
        case .failure:
            break
        }
    }
    
    private func parse(
        _ response: some JsonModel
    ) -> (vms: [any Hashable], nextUrl: String?) {
        
        switch results {
        case .characters:
            if let resp = response as? RMGetCharactersResponse {
                return (resp.results
                    .compactMap {
                        RMCharacterCollectionViewCellViewModel(
                            characterName: $0.name,
                            characterStatus: $0.status,
                            characterImageUrl: URL(string: $0.image)
                        )
                    },
                        resp.info.next
                )
            }
        case .locations:
            if let resp = response as? RMGetLocationsResponse {
                return (resp.results
                    .compactMap {
                        RMLocationTableViewCellViewModel(location: $0)
                    },
                        resp.info.next
                )
            }
        case .episodes:
            if let resp = response as? RMGetEpisodesResponse {
                return (resp.results
                    .compactMap {
                        RMCharacterEpisodeCollectionViewCellViewModel(
                            episodeDataURL: URL(string: $0.url),
                            service: self.service
                        )
                    },
                        resp.info.next
                )
            }
        }
        return ([], nil)
    }
    
    private func updateResults(
        with newResults: [any Hashable],
        nextUrl: String?,
        completion: @escaping ([any Hashable]) -> Void
    ) {
        switch results {
        case .characters(let existingResults):
            results = .characters(
                existingResults + 
                (newResults as! [RMCharacterCollectionViewCellViewModel])
            )
        case .locations(let existingResults):
            results = .locations(
                existingResults + 
                (newResults as! [RMLocationTableViewCellViewModel])
            )
        case .episodes(let existingResults):
            results = .episodes(
                existingResults + 
                (newResults as! [RMCharacterEpisodeCollectionViewCellViewModel])
            )
        }
        self.nextUrl = nextUrl
        DispatchQueue.main.async {
            self.isLoadingMoreResults = false
            completion(newResults)
        }
    }
}
