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
    
    private var apiInfo: RMGetLocationsResponse.Info?
    
    public private(set) var cellViewModels: [RMLocationTableViewCellViewModel] = []
    
    private let service: Service
    
    init(service: Service) {
        self.service = service
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
}
