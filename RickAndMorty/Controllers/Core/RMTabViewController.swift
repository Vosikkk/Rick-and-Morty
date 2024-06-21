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
        let charactersVC = RMCharcterViewController()
        let locationsVC = RMLocationViewController()
        let episodesVC = RMEpisodeViewController()
        let settingsVC = RMSettingsViewController()
        
        charactersVC.navigationItem.largeTitleDisplayMode = .automatic
        locationsVC.navigationItem.largeTitleDisplayMode = .automatic
        episodesVC.navigationItem.largeTitleDisplayMode = .automatic
        settingsVC .navigationItem.largeTitleDisplayMode = .automatic
        
        let nv1 = UINavigationController(rootViewController: charactersVC)
        let nv2 = UINavigationController(rootViewController: locationsVC)
        let nv3 = UINavigationController(rootViewController: episodesVC)
        let nv4 = UINavigationController(rootViewController: settingsVC)
        
        
        nv1.tabBarItem = UITabBarItem(
            title: "Characters",
            image: UIImage(systemName: "person"),
            tag: 1
        )
        
        nv2.tabBarItem = UITabBarItem(
            title: "Locations",
            image: UIImage(systemName: "globe"),
            tag: 2
        )
        
        nv3.tabBarItem = UITabBarItem(
            title: "Episodes",
            image: UIImage(systemName: "tv "),
            tag: 3
        )
        
        nv4.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            tag: 4
        )
        
        for nav in  [nv1, nv2, nv3, nv4] {
            nav.navigationBar.prefersLargeTitles = true
        }
        
        setViewControllers(
             [nv1, nv2, nv3, nv4],
             animated: true)
    }

}

