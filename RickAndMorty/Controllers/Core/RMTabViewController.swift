//
//  RMTabViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import UIKit


/// Controller to house tabs and root tab controllers
final class RMTabViewController: UITabBarController {

    private let service: Service = RMService(cache: RMAPICacheManager(), imageLoader: RMImageLoader())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let viewControllers = TabItems.allCases
            .map { createNavController(for: $0) }
        
        setViewControllers(viewControllers, animated: true)
    }
    
    private func createNavController(for tab: TabItems) -> UINavigationController {
        let vc = createVC(for: tab)
        vc.title = tab.title
        vc.navigationItem.largeTitleDisplayMode = .automatic
        let nv = UINavigationController(rootViewController: vc)
        nv.tabBarItem = UITabBarItem(
            title: tab.title,
            image: tab.image,
            tag: tab.rawValue)
        nv.navigationBar.prefersLargeTitles = true
        return nv
    }
    
    private func createVC(for tab: TabItems) -> UIViewController {
        switch tab {
        case .characters:
            return RMCharacterViewController(service: service)
        case .locations:
            return RMLocationViewController(service: service)
        case .episodes:
            return RMEpisodeViewController(service: service)
        case .settings:
            return RMSettingsViewController()
        }
    }
}

