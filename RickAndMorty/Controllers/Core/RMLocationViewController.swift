//
//  RMLocationViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import UIKit


/// Controller to show and search for Locations
final class RMLocationViewController: UIViewController, CoordinatedController {
   
    
    weak var coordinator: MainCoordinator?
    
    private let primaryView: RMLocationView
    
    private let locationVM: RMLocationViewViewModel
    
    init(locationVM: RMLocationViewViewModel) {
        self.locationVM = locationVM
        primaryView = RMLocationView()
        super.init(nibName: nil, bundle: nil)
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        primaryView.delegate = self
        view.addSubview(primaryView)
        view.backgroundColor = .systemBackground
        addSearchButton()
        setConstraints()
        locationVM.delegate = self 
        locationVM.fetchLocations()
    }
    
    private func addSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(didTapSearch))
    }
    
    @objc
    private func didTapSearch() {
        coordinator?.search(config: .init(type: .location))
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            primaryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            primaryView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            primaryView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            primaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension RMLocationViewController: RMLocationViewViewModelDelegate {
    func didFetchInitialLocations() {
        primaryView.configure(with: locationVM)
    }
}

extension RMLocationViewController: RMLocationViewDelegate {
    
    func rmLocationView(
        _ locationView: RMLocationView,
        didSelect location: RMLocation
    ) {
        coordinator?.locationDetail(location: location)
    }
}
