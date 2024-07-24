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
    
    private var searchResultHandler: ((any SearchResultViewModel) -> Void)?
    
    private var noResultsHandler: (() -> Void)?
    
    private var searchResultModel: (any ResponseModel)?
    
    // MARK: - Init
    
    init(config: Config, service: Service) {
        self.config = config
        self.service = service
    }
    
    // MARK: - Methods
    
    public func registerSearchResultsHandler(
        _ block: @escaping (any SearchResultViewModel) -> Void
    ) {
        self.searchResultHandler = block
    }
    
    public func registerNoResultsHandler(
        _ block: @escaping () -> Void
    ) {
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
        return cast(
            searchResultModel,
            to: RMGetLocationsResponse.self)?.results[index]
    }
    
    public func characterSearchResult(at index: Int) -> RMCharacter? {
        return cast(
            searchResultModel,
            to: RMGetCharactersResponse.self)?.results[index]
    }
    
    public func episodeSearchResult(at index: Int) -> RMEpisode? {
        return cast(
            searchResultModel,
            to: RMGetEpisodesResponse.self)?.results[index]
    }
    
    public func executeSearch() {
        
        guard !searchText.trimmingCharacters(
            in: .whitespaces
        ).isEmpty else { return }
        
        
        let request: RMRequest = RMRequest(
            endpoint: config.type.endpoint,
            queryParameters: combinedQueryParameters
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
    
    private func fetch<T: ResponseModel>(
        _ request: RMRequest,
        for type: T.Type
    )  {
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
    
    private func processSearchResults(for model: some ResponseModel) {
        
        let searchResVM: any SearchResultViewModel
        
        switch model {
        case let characterResults as RMGetCharactersResponse:
            let dataProcessor = DataProcessor<CharacterMapper, RMGetCharactersResponse>(
                mapper: CharacterMapper(
                    service: service
                )
            )
            dataProcessor.handleInitial(characterResults)
            
            searchResVM = RMSearchResultViewModel(
                service: service,
                dataProcessor: dataProcessor,
                type: RMGetCharactersResponse.self
            )
        
        case let locationResults as RMGetLocationsResponse:
            let dataProcessor = DataProcessor<LocationMapper, RMGetLocationsResponse>(
                mapper: LocationMapper()
            )
            dataProcessor.handleInitial(locationResults)
            searchResVM = RMSearchResultViewModel(
                service: service,
                dataProcessor: dataProcessor,
                type: RMGetLocationsResponse.self
            )

        case let episodeResults as RMGetEpisodesResponse:
            let dataProcessor = DataProcessor<EpisodeMapper, RMGetEpisodesResponse>(
                mapper: EpisodeMapper(
                    service: service
                )
            )
            dataProcessor.handleInitial(episodeResults)
            searchResVM = RMSearchResultViewModel(
                service: service,
                dataProcessor: dataProcessor,
                type: RMGetEpisodesResponse.self
            )
        default:
            handleNoResults()
            return
        }
        
        searchResultModel = model
        searchResultHandler?(searchResVM)
    }
    
    private func cast<T>(
        _ model: (any ResponseModel)?,
        to type: T.Type
    ) -> T? {
        return model as? T
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
            .compactMap {
                URLQueryItem(
                    name: $0.key.queryArgument,
                    value: $0.value
                )
            }
    }
    
    private var queryParameters: [URLQueryItem] {
        [URLQueryItem(
            name: "name",
            value: searchText.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            )
        )
        ]
    }
    
    private var combinedQueryParameters: [URLQueryItem] {
        queryParameters + queryItems
    }
}
