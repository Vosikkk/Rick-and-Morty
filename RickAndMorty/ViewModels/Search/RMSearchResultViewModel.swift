//
//  RMSearchResultViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 10.07.2024.
//

import Foundation

/// View Model to handle search result view  data
final class RMSearchResultViewModel {
    
    typealias FetchResult = ([any Hashable]) -> Void
    
    // MARK: - Properties
    
    public private(set) var results: RMSearchResultType
    private var nextUrl: String?
    private let service: Service
    
    public var shouldShowLoadIndicator: Bool {
        nextUrl != nil 
    }
    
    public private(set) var isLoadingMoreResults: Bool = false {
        didSet {
            if isLoadingMoreResults {
                needToCalculateLastIndex?()
            }
        }
    }
    
    public var needToCalculateLastIndex: (() -> Void)?
    
    private let parser: RMParser
    
    // MARK: - Init
    
    init(with results: RMSearchResultType,
         and nextUrl: String?,
         service: Service
    ) {
        self.results = results
        self.nextUrl = nextUrl
        self.service = service
        parser = RMResponseParser(service: service)
    }
    
    
    // MARK: - Public methods
    
    public func fetchAdditionalResults(
        completion: @escaping FetchResult
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
    
    
    // MARK: - Private methods
    
    private func handleResults(
        request: RMRequest,
        completion: @escaping FetchResult
    ) {
        
        switch results {
        case .characters:
            service.execute(
                request,
                expecting: RMGetCharactersResponse.self,
                completion: createHandleResponseClosure(completion: completion)
            )
        case .locations:
            service.execute(
                request,
                expecting: RMGetLocationsResponse.self,
                completion: createHandleResponseClosure(completion: completion)
            )
        case .episodes:
            service.execute(
                request,
                expecting: RMGetEpisodesResponse.self,
                completion: createHandleResponseClosure(completion: completion)
            )
        }
    }
    
  
    private func handleResponse<T: JsonModel>(
        result: Result<T, Error>,
        completion: @escaping FetchResult
    ) {
        switch result {
        case .success(let responseModel):
            do {
                let newRes = try parseResponse(responseModel)
                updateResults(
                    with: newRes.vms,
                    nextUrl: newRes.nextUrl,
                    completion: completion
                )
            } catch {
                print(error.localizedDescription)
            }
        case .failure(let error):
            print(error.localizedDescription)
            isLoadingMoreResults = false
        }
    }
    
    private func parseResponse(
        _ response: some JsonModel
    ) throws -> (vms: [any Hashable], nextUrl: String?) {
        
        switch results {
        case .characters:
            return try parser.parseCharacters(from: response)
        case .locations:
            return try parser.parseLocations(from: response)
        case .episodes:
            return try parser.parseEpisodes(from: response)
        }
    }
    
    private func updateResults(
        with newResults: [any Hashable],
        nextUrl: String?,
        completion: @escaping FetchResult
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
    
    private func createHandleResponseClosure<T: JsonModel>(
        completion: @escaping FetchResult
    ) -> (Result<T, Error>) -> Void {
        return { [weak self] res in
            self?.handleResponse(result: res, completion: completion)
        }
    }
}

enum CastError: Error {
    case cannotCastCharacters
    case cannotCastLocations
    case cannotCastEpisodes
    
    var localizedDescription: String {
        switch self {
        case .cannotCastCharacters:
            return "Failed to cast to RMGetCharactersResponse."
        case .cannotCastLocations:
            return "Failed to cast to RMGetLocationsResponse."
        case .cannotCastEpisodes:
            return "Failed to cast to RMGetEpisodesResponse."
        }
    }
}
