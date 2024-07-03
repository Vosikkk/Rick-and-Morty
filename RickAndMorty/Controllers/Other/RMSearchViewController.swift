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
    
    // MARK: - Init
    
    init(config: Config) {
        self.searchVM = RMSearchViewViewModel(config: config)
        self.searchView = RMSearchView(vm: searchVM)
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = searchVM.title
        view.backgroundColor = .systemBackground
        view.addSubview(searchView)
        setConstraints()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Search",
            style: .done,
            target: self,
            action: #selector(didTapExecuteSearch)
        )
    }
    
    @objc
    private func didTapExecuteSearch() {
        
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

// MARK: - Netsed type

extension RMSearchViewController {
    
    struct Config {
        let type: `Type`
        
        enum `Type` {
            case character
            case episode
            case location
            
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
