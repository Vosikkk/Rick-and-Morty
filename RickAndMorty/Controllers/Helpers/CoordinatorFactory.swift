//
//  CoordinatorFactory.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 26.07.2024.
//

import UIKit

final class CoordinatorFactory {
    
    private let service: Service
    
    private let modelBuilder: ModelBuilder
    
    init(service: Service, modelBuilder: ModelBuilder) {
        self.service = service
        self.modelBuilder = modelBuilder
    }
   
    func makeCoordinator(
        navController: UINavigationController = UINavigationController(),
        tab: TabItems) -> Coordinator {
            MainCoordinator(
                navigationController: navController,
                service: service,
                tabItem: tab,
                modelBuilder: modelBuilder
            )
        }
            
}

