//
//  TabItems.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import UIKit


protocol TabItem {
    var title: String { get }
    var image: UIImage? { get }
  
}



/// Represents the title, icon, and each instance of the view controller for a tab.
enum TabItems: Int, CaseIterable, TabItem {
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
}
