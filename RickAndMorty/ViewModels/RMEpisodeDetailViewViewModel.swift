//
//  RMEpisodeDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 27.06.2024.
//

import Foundation

final class RMEpisodeDetailViewViewModel {
    
    private let endpointUrl: URL?
    private let service: Service
    
    init(endpointUrl: URL?, service: Service) {
        self.service = service
        self.endpointUrl = endpointUrl
        fetchEpisodeData()
    }
    
    
    private func fetchEpisodeData() {
        guard let endpointUrl,
                let request = RMRequest(url: endpointUrl) else {
            return
        }
        service.execute(request, expecting: RMEpisode.self) { res in
            switch res {
            case .success(let success):
                print(String(describing: success))
            case .failure(_):
                break
            }
        }
    }
}
