//
//  RMTabViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import UIKit

final class RMTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let viewControllers = TabItems.allCases.map { createNavController(for: $0) }
        setViewControllers(viewControllers, animated: true)
    }
    
    private func createNavController(for tab: TabItems) -> UINavigationController {
        let vc = tab.viewController()
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
}

enum TabItems: Int, CaseIterable {
    case characters = 1, locations, episodes, settings
    
    var title: String {
        switch self {
        case .characters:
            "Characters"
        case .locations:
            "Locations"
        case .episodes:
            "Episodes"
        case .settings:
            "Settings"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .characters:
            UIImage(systemName: "person")
        case .locations:
            UIImage(systemName: "globe")
        case .episodes:
            UIImage(systemName: "tv")
        case .settings:
            UIImage(systemName: "gear")
        }
    }
    
    func viewController() -> UIViewController {
        switch self {
        case .characters:
            return RMCharcterViewController()
        case .locations:
            return RMLocationViewController()
        case .episodes:
            return RMEpisodeViewController()
        case .settings:
            return RMSettingsViewController()
        }
    }
}
