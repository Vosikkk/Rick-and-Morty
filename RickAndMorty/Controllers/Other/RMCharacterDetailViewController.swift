//
//  RMCharacterDetailViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 23.06.2024.
//

import UIKit

/// Controller to show info about single character
final class RMCharacterDetailViewController: UIViewController {

    private let detailVM: RMCharacterDetailViewViewModel
    
    init(viewModel: RMCharacterDetailViewViewModel) {
        detailVM = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = detailVM.title
    }
}
