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
    
    private var searchResultHandler: (() -> Void)?
    
    
    // MARK: - Init
    
    init(config: Config, service: Service) {
        self.config = config
        self.service = service
    }
    
    // MARK: - Methods
    
    public func registerSearchResultsHandler(_ block: @escaping () -> Void) {
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
    
    public func exucuteSearch() {
        var queryParameters: [URLQueryItem] = [
            URLQueryItem(name: "name", value: searchText)
        ]
        
        queryParameters.append(contentsOf: queryItems)
        
        let request: RMRequest = RMRequest(
            endpoint: config.type.endpoint,
            queryParameters: queryParameters
        )
        service.execute(
            request,
            expecting: RMGetCharactersResponse.self
        ) { res in
            switch res {
            case .success(let model):
                print(model.results.count)
            case .failure:
                break
            }
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
