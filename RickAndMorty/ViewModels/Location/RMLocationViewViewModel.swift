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
    
    public var isLoadingMoreLocations: Bool = false
    
    public var shouldShowLoadIndicator: Bool {
        apiInfo?.next != nil
    }
    
    private var didFinishPagination: (() -> Void)?
    
    private var locations: [RMLocation] = [] {
        didSet {
            for location in locations {
                let vm = RMLocationTableViewCellViewModel(location: location)
                if !cellViewModels.contains(vm) {
                    cellViewModels.append(vm)
                }
            }
        }
    }
    
    private var hasMoreResults: Bool {
        false
    }
    
    private(set) var apiInfo: RMGetLocationsResponse.Info?
    
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
            case .success(let model):
                self?.apiInfo = model.info
                self?.locations = model.results
                DispatchQueue.main.async {
                    self?.delegate?.didFetchInitialLocations()
                }
            case .failure:
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
                let moreRes = responseModel.results
                let info = responseModel.info
                apiInfo = info
                cellViewModels.append(contentsOf: moreRes
                    .compactMap {
                        RMLocationTableViewCellViewModel(location: $0)
                    }
                )
                DispatchQueue.main.async {
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
        guard index < locations.count, index >= 0 else {
            return nil
        }
        return locations[index]
    }
}
