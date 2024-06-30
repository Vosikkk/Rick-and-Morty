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
    
    private var locations: [RMLocation] = []
    
    private var hasMoreResults: Bool {
        false
    }
    
    private var apiInfo: RMGetLocationsResponse.Info?
    
    private let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    public func fetchLocations() {
        let request = RMRequest(endpoint: .location)
        service.execute(request, expecting: RMGetLocationsResponse.self) { [weak self] res in
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
