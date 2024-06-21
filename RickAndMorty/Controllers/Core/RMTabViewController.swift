//
//  RMTabViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import UIKit


/// Controller to house tabs and root tab controllers
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

