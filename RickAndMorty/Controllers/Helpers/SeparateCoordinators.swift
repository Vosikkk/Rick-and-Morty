//
//  SeparateCoordinators.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 26.07.2024.
//

import UIKit

final class CoordinatorFactory {
    
    private let service: Service
    
    init(service: Service) {
        self.service = service
    }
   
    func makeCoordinator(
        navController: UINavigationController = UINavigationController(),
        tab: TabItems) -> Coordinator {
            BaseCoordinator(navigationController: navController, service: service, tab: tab)
        }
            
}

