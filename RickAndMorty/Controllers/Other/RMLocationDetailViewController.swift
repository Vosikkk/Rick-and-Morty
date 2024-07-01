//
//  RMLocationDetailViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 01.07.2024.
//

import UIKit

final class RMLocationDetailViewController: UIViewController {
   
    private let service: Service
    private let locationDetailVM: RMLoactionDetailViewViewModel
    
    private let detailView: RMLocationDetailView = RMLocationDetailView()
    
    
    // MARK: - Init
    
    init(location: RMLocation, service: Service) {
        self.service = service
        self.locationDetailVM = RMLoactionDetailViewViewModel(
            endpointUrl: URL(string: location.url),
            service: service
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(detailView)
        setConstraints()
        detailView.delegate = self
        title = "Location"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare))
        
        locationDetailVM.delegate = self
        locationDetailVM.fetchData()
    }
    
    @objc
    private func didTapShare() {
        
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            detailView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - View Model Delegate

extension RMLocationDetailViewController: RMLocationDetailViewViewModelDelegate {
    func didFetchLocationDetails() {
       detailView.configure(with: locationDetailVM)
    }
}

// MARK: - View Delegate

extension RMLocationDetailViewController: RMLocationDetailViewDelegate {
    
    func rmLocationDetailView(
        _ detailView: RMLocationDetailView,
        didSelect character: RMCharacter
    ) {
        let vc = RMCharacterDetailViewController(
            viewModel: .init(
                character: character,
                service: service
            ),
            service: service
        )
        vc.title = character.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
