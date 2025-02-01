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
    
  
    private let builder: ModelBuilder
    
    
    // MARK: - Init
    
    init(config: Config, service: Service) {
        self.config = config
        self.service = service
        builder = ModelBuilder(service: service)
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
            guard let self else { return }
            switch res {
            case .success(let model):
                if let vm = builder.buildSearchResultViewModel(kindOf: model) {
                    searchResultModel = model
                    searchResultHandler?(vm)
                }
            case .failure:
                noResultsHandler?()
            }
        }
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




final class ModelBuilder {
    
    private let service: Service
    
    private let dataProcessorFactory: DataProcessorFactory
    
    private let fetchStrategy: FetchStrategyFactory
    
    private let mapperFactory: MapperFactory
    
    init(service: Service) {
        self.service = service
        dataProcessorFactory = DataProcessorFactory(service: service)
        fetchStrategy = FetchStrategyFactory()
        mapperFactory = MapperFactory()
    }
    
    
    public func buildLocationViewModel() -> RMLocationViewViewModel {
        RMLocationViewViewModel(
            service: service,
            dataProcessor: dataProcessorFactory.createLocationProcessor(
                mapper: mapperFactory.locationMapper()
            )
        )
    }
    
    
    public func buildEpisodeListViewViewModel() -> RMEpisodeListViewViewModel {
        RMEpisodeListViewViewModel(
            service: service,
            dataProcessor: dataProcessorFactory.createEpisodeProcessor(
                mapper: mapperFactory.episodeMapper(
                    service: service)
            )
        )
    }
    
    
    public func buildSearchResultViewModel(kindOf response: any ResponseModel) -> (any SearchResultViewModel)? {
        switch response {
        case let characterResp as RMGetCharactersResponse:
            return RMSearchResultViewModel(
                dataProcessor: dataProcessorFactory.createCharacterProcessor(from: characterResp,
                mapper: mapperFactory.characterMapper(service: service)),
                strategy: fetchStrategy.charactersStartegy(service: service))
                
            
        case let locationResp as RMGetLocationsResponse:
            return RMSearchResultViewModel(
                dataProcessor: dataProcessorFactory.createLocationProcessor(from: locationResp,
                mapper: mapperFactory.locationMapper()),
                strategy: fetchStrategy.locationStrategy(service: service))
            
        case let episodeResp as RMGetEpisodesResponse:
            return RMSearchResultViewModel(
                dataProcessor: dataProcessorFactory.createEpisodeProcessor(from: episodeResp,
                mapper: mapperFactory.episodeMapper(service: service)),
                strategy: fetchStrategy.episodeStrategy(service: service))
        default:
            return nil
        }
    }
}


final class DataProcessorFactory {
    
    let service: Service
    
    
    init(service: Service) {
        self.service = service
    }
    
    public func createCharacterProcessor(
        from response: RMGetCharactersResponse? = nil, mapper: CharacterMapper
    ) -> DataProcessor<CharacterMapper, RMGetCharactersResponse> {
        if let response {
            return DataProcessor(response: response, mapper: mapper)
        }
        return DataProcessor(mapper: mapper)
    }
    
    public func createLocationProcessor(
        from response: RMGetLocationsResponse? = nil, mapper: LocationMapper
    ) -> DataProcessor<LocationMapper, RMGetLocationsResponse> {
        if let response {
            return DataProcessor(response: response, mapper: mapper)
        }
        return DataProcessor(mapper: mapper)
    }
    
    public func createEpisodeProcessor(
        from response: RMGetEpisodesResponse? = nil, mapper: EpisodeMapper
    ) -> DataProcessor<EpisodeMapper, RMGetEpisodesResponse> {
        if let response {
            return DataProcessor(response: response, mapper: mapper)
        }
        return DataProcessor(mapper: mapper)
    }
    
    
}

struct MapperFactory {
    
    public func episodeMapper(service: Service) -> EpisodeMapper {
        EpisodeMapper(service: service)
    }
    
    public func characterMapper(service: Service) -> CharacterMapper {
        CharacterMapper(service: service)
    }
    
    public func locationMapper() -> LocationMapper {
        LocationMapper()
    }
}

struct FetchStrategyFactory {
    
    public func episodeStrategy(service: Service) -> EpisodeResponse {
         EpisodeResponse(service: service)
    }
    
    public func locationStrategy(service: Service) -> LocationResponse {
        LocationResponse(service: service)
    }
    
    public func charactersStartegy(service: Service) -> CharacterResponse {
        CharacterResponse(service: service)
    }
}

