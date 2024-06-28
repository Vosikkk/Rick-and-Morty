//
//  RMSettingsViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import UIKit


/// Controller to show various app options and settings
final class RMSettingsViewController: UIViewController {

    
    private let settingsVM: RMSettingsViewViewModel = RMSettingsViewViewModel(
        cellViewModels: RMSettingsOption.allCases
            .compactMap { .init(type: $0) }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
