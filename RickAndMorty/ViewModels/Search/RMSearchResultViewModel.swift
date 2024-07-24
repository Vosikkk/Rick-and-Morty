//
//  RMSearchResultViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 10.07.2024.
//

import Foundation

public protocol SearchResultViewModel {
    
    associatedtype ViewModel: Hashable
    
    var data: [ViewModel] { get }
    
    var isLoadingMoreResults: Bool { get }
    
    var shouldShowLoadIndicator: Bool { get }
    
    func fetchAdditionalResults(completion: @escaping ([IndexPath]) -> Void)
}


final class RMSearchResultViewModel<DataProcessor: DataProcess, T: ResponseModel>: SearchResultViewModel {
    
    typealias ViewModel = DataProcessor.ViewModel
    
    var data: [ViewModel] {
        dataProcessor.cellViewModels
    }
    private var nextUrl: String? {
        dataProcessor.apiInfo?.next
    }
    
    private var calculator: CalculatorIndexPaths
    
    private let service: Service
    
    private let dataProcessor: DataProcessor
    
    private let type: T.Type
    
    public private(set) var isLoadingMoreResults: Bool = false {
        didSet {
            if isLoadingMoreResults,
               calculator._lastIndex != dataProcessor.cellViewModels.endIndex {
                calculator._lastIndex = dataProcessor.cellViewModels.endIndex
            }
        }
    }
    
    public var shouldShowLoadIndicator: Bool {
        nextUrl != nil
    }
    
    
    init(
        service: Service,
        dataProcessor: DataProcessor,
        type: T.Type
    ) {
        self.service = service
        self.dataProcessor = dataProcessor
        self.type = type
        self.calculator = .init(lastIndex: dataProcessor.cellViewModels.endIndex)
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
                
                guard let response = responseModel as? DataProcessor.Response else {
                    isLoadingMoreResults = false
                    return
                }
                
                dataProcessor.handleAdditional(response)
                DispatchQueue.mainAsyncIfNeeded {
                    self.isLoadingMoreResults = false
                    completion(self.calculator.calculateIndexPaths(
                        count: response.results.count)
                    )
                }
            case .failure(let failure):
                isLoadingMoreResults = false
                print(failure)
            }
        }
    }
}

