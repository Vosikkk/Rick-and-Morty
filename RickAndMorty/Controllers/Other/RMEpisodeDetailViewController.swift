//
//  RMEpisodeDetailViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 26.06.2024.
//

import UIKit

/// VC to show details about single episode
final class RMEpisodeDetailViewController: UIViewController, CoordinatedController {

    private let service: Service
    private let episodeDetailVM: RMEpisodeDetailViewViewModel
    
    private let detailView: RMEpisodeDetailView = RMEpisodeDetailView()
    
    weak var coordinator: MainCoordinator?
    
    
    // MARK: - Init
    
    init(url: URL?, service: Service) {
        self.service = service
        self.episodeDetailVM = .init(endpointUrl: url, service: service)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(detailView)
        detailView.delegate = self
        setConstraints()
        title = "Episode"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self, 
            action: #selector(didTapShare))
        
        episodeDetailVM.delegate = self
        episodeDetailVM.fetchData()
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

extension RMEpisodeDetailViewController: RMEpisodeDetailViewViewModelDelegate {
   
    func didFetchEpisodeDetails() {
        detailView.configure(with: episodeDetailVM)
    }
}

// MARK: - View Delegate

extension RMEpisodeDetailViewController: RMEpisodeDetailViewDelegate {
    func rmEpisodeDetailView(
        _ detailView: RMEpisodeDetailView,
        didSelect character: RMCharacter
    ) {
        coordinator?.characterDetail(character: character)
    }
}
