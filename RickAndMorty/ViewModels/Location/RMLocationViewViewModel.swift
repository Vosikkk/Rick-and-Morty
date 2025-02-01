//
//  RMLocationViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 30.06.2024.
//

import Foundation

protocol RMLocationViewViewModelDelegate: AnyObject {
    func didFetchInitialLocations()
}


final class RMLocationViewViewModel {
    
    typealias ViewModel = RMLocationTableViewCellViewModel
    
    // MARK: - Private Properties
    
    private let dataProcessor: DataProcessor<LocationMapper, RMGetLocationsResponse>
    
    private let service: Service

    private var calculator: CalculatorIndexPaths
    
    private var didFinishPagination: (() -> Void)?
    
    private var apiInfo: Info? {
        dataProcessor.apiInfo
    }
    
    // MARK: - Public Properties
    
    public weak var delegate: RMLocationViewViewModelDelegate?
    
    public var isLoadingMoreLocations: Bool = false {
        didSet {
            if isLoadingMoreLocations,
                calculator._lastIndex != dataProcessor.items.endIndex {
                calculator._lastIndex = dataProcessor.items.endIndex
            }
        }
    }
    
    public var shouldShowLoadIndicator: Bool {
        apiInfo?.next != nil
    }
    
    public var cellViewModels: [ViewModel] {
        return dataProcessor.cellViewModels
    }
    
    
    // MARK: - Init 
    
    init(service: Service, dataProcessor: DataProcessor<LocationMapper, RMGetLocationsResponse>) {
        self.service = service
        self.dataProcessor = dataProcessor
        self.calculator = .init()
    }
    
    
    // MARK: - Methods 
    
    public func registerDidFinishPaginationBlock(
        _ block: @escaping () -> Void
    ) {
        self.didFinishPagination = block
    }
    
    public func fetchLocations() {
        service.execute(
            RMRequest(endpoint: .location),
            expecting: RMGetLocationsResponse.self
        ) { [weak self] res in
            guard let self else { return }
    
            switch res {
            case .success(let responseModel):
                dataProcessor.handleInitial(responseModel)
               
                DispatchQueue.mainAsyncIfNeeded {
                    self.delegate?.didFetchInitialLocations()
                }
            
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    /// Paginate if additional locations are needed
    public func fetchAdditionalLocations() {
        guard !isLoadingMoreLocations,
              let nextURLString = apiInfo?.next,
              let url = URL(string: nextURLString) else { return }
        
        isLoadingMoreLocations = true
        
        guard let request = RMRequest(url: url) else {
            isLoadingMoreLocations = false
            return
        }
        
        service.execute(
            request,
            expecting: RMGetLocationsResponse.self
        ) { [weak self] res in
            guard let self else { return }
            switch res {
            case .success(let responseModel):
                
                dataProcessor.handleAdditional(responseModel)
                
                DispatchQueue.mainAsyncIfNeeded {
                    self.isLoadingMoreLocations = false
                    self.didFinishPagination?()
                }
            
            case .failure(let failure):
                print(String(describing: failure))
                isLoadingMoreLocations = false
            }
        }
    }
    
    public func location(at index: Int) -> RMLocation? {
        return dataProcessor.item(at: index)
    }
}
