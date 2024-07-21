//
//  RMSearchResultViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 10.07.2024.
//

import Foundation

protocol SearchResultViewModel {
    
    associatedtype ViewModel: Hashable
    
    var data: [ViewModel] { get }
    
    var nextUrl: String? { get }
    
    var isLoadingMoreResults: Bool { get }
    
    var shouldShowLoadIndicator: Bool { get }
    
    func fetchAdditionalResults(completion: @escaping ([IndexPath]) -> Void)
}


final class RMSearchResultViewModel<Mapper: Map, T: ResponseModel>: SearchResultViewModel {
    
    typealias ViewModel = Mapper.ViewModel
    
    private(set) var data: [ViewModel]
    private(set) var nextUrl: String?
    
    private var calculator: CalculatorIndexPaths
    
    private let service: Service
    
    private let mapper: Mapper
    
    private let type: T.Type
    
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
        data: [ViewModel],
        nextUrl: String?,
        service: Service,
        mapper: Mapper,
        type: T.Type
    ) {
        self.data = data
        self.nextUrl = nextUrl
        self.service = service
        self.mapper = mapper
        self.type = type
        self.calculator = .init(lastIndex: data.endIndex)
    }
    
    
    
    func fetchAdditionalResults(completion: @escaping ([IndexPath]) -> Void) {
       
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
        
        service.execute(request, expecting: type) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let responseModel):
                if let resp = responseModel.results as? [Mapper.JsModel] {
                    update(nextUrl: responseModel.info.next,
                           data: mapper.map(from: resp),
                           completion: completion
                    )
            }
            case .failure(let failure):
                isLoadingMoreResults = false
                print(failure)
            }
        }
    }
    
    
    private func update(
        nextUrl: String?,
        data: [Mapper.ViewModel],
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
