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
    
    private var noResultsHandler: (() -> Void)?
    
    private var searchResultModel: JsonModel?
    
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
    
    public func registerNoResultsHandler(_ block: @escaping () -> Void) {
        self.noResultsHandler = block
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
    
    public func locationSearchResult(at index: Int) -> RMLocation? {
        guard let model = cast(searchResultModel, to: RMGetLocationsResponse.self) else {
           return nil
        }
        return model.results[index]
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
        case .location:
            fetch(request, for: RMGetLocationsResponse.self)
        case .episode:
            fetch(request, for: RMGetEpisodesResponse.self)
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
                self?.handleNoResults()
            }
        }
    }
    
    private func handleNoResults() {
        noResultsHandler?()
    }
    
    private func processSearchResults(for model: some JsonModel) {
        
        var resultsVM: RMSearchResultViewModel?
        
        if let characterResults = cast(model, to: RMGetCharactersResponse.self) {
            resultsVM = .characters(characterResults.results
                .compactMap {
                    .init(
                        characterName: $0.name,
                        characterStatus: $0.status,
                        characterImageUrl: URL(string: $0.image)
                    )
                }
            )
           
        } else if let locationResults = cast(model, to: RMGetLocationsResponse.self) {
            resultsVM = .locations(locationResults.results
                .compactMap {
                    .init(location: $0)
                }
            )
        } else if let episodeResults = cast(model, to: RMGetEpisodesResponse.self) {
            resultsVM = .episodes(episodeResults.results
                .compactMap {
                    .init(episodeDataURL: URL(string: $0.url), service: service)
                }
            )
           
        }
    
        if let resultsVM {
            searchResultModel = model
            searchResultHandler?(resultsVM)
        } else {
            handleNoResults()
        }
    }
    
    private func cast<T>(_ model: JsonModel?, to type: T.Type) -> T? {
        if let res = model as? T {
            return res
        }
        return nil
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
