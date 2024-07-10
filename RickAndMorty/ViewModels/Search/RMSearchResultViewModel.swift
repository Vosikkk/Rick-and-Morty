//
//  RMSearchResultViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 10.07.2024.
//

import Foundation

final class RMSearchResultViewModel {
    
    public private(set) var results: RMSearchResultType
    private var nextUrl: String?
    private let service: Service
    
    public var shouldShowLoadIndicator: Bool {
        nextUrl != nil 
    }
    
    public private(set) var isLoadingMoreResults: Bool = false
        
    
    init(with results: RMSearchResultType, 
         and nextUrl: String?,
         service: Service
    ) {
        self.results = results
        self.nextUrl = nextUrl
        self.service = service
    }
    
    public func fetchAdditionalLocations(completion: @escaping ([RMLocationTableViewCellViewModel]) -> Void) {
        
        guard !isLoadingMoreResults,
              let nextURLString = nextUrl,
              let url = URL(string: nextURLString) else { return }
        
        isLoadingMoreResults = true
        
        guard let request = RMRequest(url: url) else {
            isLoadingMoreResults = false
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
                nextUrl = info.next
                
                let newRes = handleResults(additionalLocationVms: moreRes
                    .compactMap {
                        RMLocationTableViewCellViewModel(location: $0)
                    }
                )
                
                DispatchQueue.main.async {
                    self.isLoadingMoreResults = false
                    completion(newRes)
                }
            case .failure(let failure):
                print(String(describing: failure))
                isLoadingMoreResults = false
            }
        }
    }
    
    private func handleResults(additionalLocationVms: [RMLocationTableViewCellViewModel]) -> [RMLocationTableViewCellViewModel] {
        var res: [RMLocationTableViewCellViewModel] = []
        switch results {
        case .characters, .episodes:
            break
        case .locations(let existingResults):
            res = existingResults + additionalLocationVms
            results = .locations(res)
        }
        return res
    }
}
