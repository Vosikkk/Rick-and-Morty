//
//  RMSearchViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 03.07.2024.
//

import Foundation

final class RMSearchViewViewModel {
    
    typealias Config = RMSearchViewController.Config
    
    typealias Option = RMSearchInputViewViewModel.DynamicOption
    
    
    // MARK: - Properties
    
    private let config: Config
    
    private let service: Service
    
    private var optionMap: [Option: String] = [:]
    
    private var optionMapUpdate: (((Option, String)) -> Void)?
    
    private var searchText: String = ""
    
    private var searchResultHandler: ((RMSearchResultViewModel) -> Void)?
    
    
    // MARK: - Init
    
    init(config: Config, service: Service) {
        self.config = config
        self.service = service
    }
    
    // MARK: - Methods
    
    public func registerSearchResultsHandler(
        _ block: @escaping (RMSearchResultViewModel) -> Void
    ) {
        self.searchResultHandler = block
    }
    
    public func set(value: String, for option: Option) {
        optionMap[option] = value
        optionMapUpdate?((option, value))
    }
    
    public func registerOptionChange(
        _ block: @escaping ((Option, String)) -> Void
    ) {
        optionMapUpdate = block
    }
    
    public func set(query text: String) {
        searchText = text
    }
    
    public func executeSearch() {
        var queryParameters: [URLQueryItem] = [
            URLQueryItem(
                name: "name",
                value: searchText.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                )
            )
        ]
        
        queryParameters.append(contentsOf: queryItems)
        
        let request: RMRequest = RMRequest(
            endpoint: config.type.endpoint,
            queryParameters: queryParameters
        )
        
        switch config.type.endpoint {
        case .character:
            fetch(request, for: RMGetCharactersResponse.self)
        case .episode:
            fetch(request, for: RMGetEpisodesResponse.self)
        case .location:
            fetch(request, for: RMGetLocationsResponse.self)
        }
    }
    
    private func fetch<T: JsonModel>(_ request: RMRequest, for type: T.Type) {
        service.execute(
            request,
            expecting: type
        ) { [weak self] res in
            switch res {
            case .success(let model):
                self?.processSearchResults(for: model)
            case .failure:
                break
            }
        }
    }
    
    private func processSearchResults(for model: some JsonModel) {
        
        var resultsVM: RMSearchResultViewModel?
        
        if let characterResults = model as? RMGetCharactersResponse {
            resultsVM = .characters(characterResults.results
                .compactMap {
                    .init(
                        characterName: $0.name,
                        characterStatus: $0.status,
                        characterImageUrl: URL(string: $0.image)
                    )
                }
            )
           
        } else if let episodeResults = model as? RMGetEpisodesResponse {
            resultsVM = .episodes(episodeResults.results
                .compactMap {
                    .init(episodeDataURL: URL(string: $0.url), service: service)
                }
            )
           
        } else if let locationResults = model as? RMGetLocationsResponse {
            resultsVM = .locations(locationResults.results
                .compactMap {
                    .init(location: $0)
                }
            )
        }
        if let resultsVM {
            searchResultHandler?(resultsVM)
        }
    }
    
    // MARK: - Computed Properties
    
    public var title: String {
        config.type.title
    }
    
    public var configType: Config.`Type` {
        config.type
    }
    
    private var queryItems: [URLQueryItem] {
        optionMap
            .enumerated()
            .compactMap { _, element in
                return URLQueryItem(
                    name: element.key.queryArgument,
                    value: element.value
                )
            }
    }
}
