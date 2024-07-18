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
    
    public weak var delegate: RMLocationViewViewModelDelegate?
    
    public var isLoadingMoreLocations: Bool = false {
        didSet {
            if isLoadingMoreLocations,
               calculator._lastIndex != locations.endIndex {
                calculator._lastIndex = locations.endIndex
            }
        }
    }
    
    public var shouldShowLoadIndicator: Bool {
        apiInfo?.next != nil
    }
    
    private var didFinishPagination: (() -> Void)?
    
    private var locations: [RMLocation] = [] {
        didSet {
            cellViewModels.append(
                contentsOf: createViewModels(
                    from: locations,
                    startingAt: calculator._lastIndex
                )
            )
        }
    }
    
    private var calculator = CalculatorIndexPaths()
    
    private var hasMoreResults: Bool {
        false
    }
    
    private(set) var apiInfo: Info?
    
    public private(set) var cellViewModels: [RMLocationTableViewCellViewModel] = []
    
    private let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
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
            switch res {
            case .success(let resp):
                self?.handleInitial(response: resp)
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
                 handleAdditional(response: responseModel)
            case .failure(let failure):
                print(String(describing: failure))
                isLoadingMoreLocations = false
            }
        }
    }
    
    private func handleAdditional(response: RMGetLocationsResponse) {
        apiInfo = response.info
        locations.append(contentsOf: response.results)
        DispatchQueue.mainAsyncIfNeeded { [weak self] in
            self?.isLoadingMoreLocations = false
            self?.didFinishPagination?()
        }
    }
    
    private func handleInitial(response: RMGetLocationsResponse) {
        apiInfo = response.info
        locations = response.results
        DispatchQueue.mainAsyncIfNeeded { [weak self] in
            self?.delegate?.didFetchInitialLocations()
        }
    }
    
    private func createViewModels(
        from locations: [RMLocation],
        startingAt index: Int
    ) -> [RMLocationTableViewCellViewModel] {
        return locations[index...]
            .map {
                RMLocationTableViewCellViewModel(location: $0)
            }
    }
    
    
    public func location(at index: Int) -> RMLocation? {
        guard index < locations.count, index >= 0 else {
            return nil
        }
        return locations[index]
    }
}
