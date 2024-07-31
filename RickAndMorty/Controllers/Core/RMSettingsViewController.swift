//
//  RMSettingsViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import StoreKit
import SafariServices
import UIKit
import SwiftUI

/// Controller to show various app options and settings
final class RMSettingsViewController: UIViewController, CoordinatedController {
    
    weak var coordinator: MainCoordinator?
    
    private var settingsHostingVC: UIHostingController<RMSettingsView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setSettingHostVC()
    }
    
    private func setSettingHostVC() {
        let vc = UIHostingController(
            rootView: RMSettingsView(
                viewModel: RMSettingsViewViewModel(
                    cellViewModels: RMSettingsOption.allCases
                        .compactMap {
                            RMSettingsCellViewModel(type: $0) { [weak self] option in
                                self?.handleTap(option: option)
                            }
                        }
                )
            )
        )
        addChild(vc)
        vc.didMove(toParent: self)
        view.addSubview(vc.view)
        setConstraints(for: vc)
        self.settingsHostingVC = vc
    }
    
    
    private func setConstraints(for vc: UIHostingController<RMSettingsView>) {
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vc.view.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            vc.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func handleTap(option: RMSettingsOption) {
        guard Thread.current.isMainThread else {  return }
        
        if let url = option.targetUrl {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        } else if option == .rateApp {
            if let windowScene = view.window?.windowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
}
