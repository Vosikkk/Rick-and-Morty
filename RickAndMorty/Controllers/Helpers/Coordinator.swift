//
//  Coordinator.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 24.07.2024.
//

import UIKit


protocol Coordinator: AnyObject {
    
    var navigationController: UINavigationController { get }
    
    func push(_ vc: CoordinatedController)
    
    func start()
}

protocol CoordinatedController: AnyObject, UIViewController {
    var coordinator: Coordinator? { get set }
}



final class BaseCoordinator: Coordinator {
    
    private(set) var navigationController: UINavigationController
    
    private let service: Service
    
    private let tab: TabItems
    
    
    init(navigationController: UINavigationController, service: Service, tab: TabItems) {
        self.navigationController = navigationController
        self.service = service
        self.tab = tab
        setNavigationController()
    }
    
    
    func setNavigationController() {
        navigationController.tabBarItem = UITabBarItem(
            title: tab.title,
            image: tab.image,
            tag: tab.rawValue)
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    
    func push(_ vc: CoordinatedController) {
        vc.coordinator = self 
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(vc, animated: true)
    }
    
    func start() {
        let vc: CoordinatedController = 
        switch tab {
        case .characters:
            RMCharacterViewController(service: service)
        case .locations:
            RMLocationViewController(service: service)
        case .episodes:
            RMEpisodeViewController(service: service)
        case .settings:
            RMSettingsViewController()
        }
        vc.title = tab.title
        vc.navigationItem.largeTitleDisplayMode = .automatic
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: true)
    }
}

