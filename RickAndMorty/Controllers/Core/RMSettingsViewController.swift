//
//  RMSettingsViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import UIKit
import SwiftUI

/// Controller to show various app options and settings
final class RMSettingsViewController: UIViewController {

    
    private let settingsVM: RMSettingsViewViewModel = RMSettingsViewViewModel(
        cellViewModels: RMSettingsOption.allCases
            .compactMap { .init(type: $0) }
    )
    
    private let settingsHostingVC: UIHostingController<RMSettingsView>
    
    
    init() {
        settingsHostingVC = UIHostingController(
            rootView: RMSettingsView(viewModel: settingsVM)
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(* , unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addChild(settingsHostingVC)
        settingsHostingVC.didMove(toParent: self)
        view.addSubview(settingsHostingVC.view)
        setConstraintsForHostingVCView()
    }
    
    
    private func setConstraintsForHostingVCView() {
        settingsHostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsHostingVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            settingsHostingVC.view.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            settingsHostingVC.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            settingsHostingVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
