//
//  RMSearchViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 27.06.2024.
//

import UIKit


///  Configurable controller to search
final class RMSearchViewController: UIViewController {
    
    private let config: Config
    
    private let searchView: RMSearchView
    
    private let searchVM: RMSearchViewViewModel
    
    private let service: Service
    
    // MARK: - Init
    
    init(config: Config, service: Service) {
        self.searchVM = RMSearchViewViewModel(config: config, service: service)
        self.searchView = RMSearchView(vm: searchVM)
        self.config = config
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.searchView.didChangeScreenTransition()
        })
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = searchVM.title
        view.backgroundColor = .systemBackground
        view.addSubview(searchView)
        setConstraints()
        searchView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Search",
            style: .done,
            target: self,
            action: #selector(didTapExecuteSearch)
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchView.presentKeyboard()
    }
    
    @objc
    private func didTapExecuteSearch() {
        searchVM.executeSearch()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            searchView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            searchView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

// MARK: - RMSearchViewDelegate

extension RMSearchViewController: RMSearchViewDelegate {
    
    func rmSearchView(_ sender: RMSearchView, didSelectEpisode episode: RMEpisode) {
        let vc = RMEpisodeDetailViewController(
            url: URL(string: episode.url),
            service: service
        )
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func rmSearchView(_ sender: RMSearchView, didSelectCharacter character: RMCharacter) {
        let vc = RMCharacterDetailViewController(
            viewModel: .init(
                character: character,
                service: service
            ),
            service: service
        )
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func rmSearchView(_ sender: RMSearchView, didSelectLocation location: RMLocation) {
        let vc = RMLocationDetailViewController(location: location, service: service)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func rmSearchView(
        _ sender: RMSearchView,
        didSelectOption option: RMSearchInputViewViewModel.DynamicOption
    ) {
        let vc = RMSearchOptionPickerViewController(option) { [weak self] selection in
            DispatchQueue.main.async {
                self?.searchVM.set(value: selection, for: option)
            }
        }
        vc.sheetPresentationController?.detents = [.medium()]
        vc.sheetPresentationController?.prefersGrabberVisible = true
        present(vc, animated: true)
    }
}

// MARK: - Netsed type

extension RMSearchViewController {
    
    struct Config {
        let type: `Type`
        
        enum `Type` {
            case character
            case episode
            case location
            
            var endpoint: RMEndpoint {
                switch self {
                case .character: return .character
                case .episode: return .episode
                case .location: return .location
                }
            }
    
            var title: String {
                switch self {
                case .character:
                    return "Search Characters"
                case .episode:
                    return "Search Episodes"
                case .location:
                    return "Search Locations"
                }
            }
        }
    }
}
