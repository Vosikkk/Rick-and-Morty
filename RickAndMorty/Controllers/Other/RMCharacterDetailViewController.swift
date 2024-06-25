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
    
    private let detailView: RMCharacterDetailView
    
  
    // MARK: - Init
    
    init(viewModel: RMCharacterDetailViewViewModel) {
        detailVM = viewModel
        detailView = RMCharacterDetailView(frame: .zero, vm: detailVM)
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
        view.addSubview(detailView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )
        setConstraints()
        detailView.collectionView?.delegate = self
        detailView.collectionView?.dataSource = self
    }
    
    @objc
    private func didTapShare() {
        
    }
    
    
   
    
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            detailView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}


// MARK: - UICollectionViewDelegate
extension RMCharacterDetailViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension RMCharacterDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        detailVM.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = detailVM.sections[section]
        switch sectionType {
        case .photo:
            return 1
        case .information(let viewModels):
            return viewModels.count
        case .episodes(let viewModels):
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sectionType = detailVM.sections[indexPath.section]
        switch sectionType {
        case .photo(let viewModel):
             let cell = dequeueCell(in: collectionView, of: RMCharacterPhotoCollectionViewCell.self, for: indexPath)
            cell.configure(with: viewModel)
            cell.backgroundColor = .systemRed
            return cell
        case .information(let viewModels):
            let cell = dequeueCell(in: collectionView, of: RMCharacterInfoCollectionViewCell.self, for: indexPath)
            cell.configure(with: viewModels[indexPath.row])
            cell.backgroundColor = .systemBlue
            return cell
        case .episodes(let viewModels):
            let cell = dequeueCell(in: collectionView, of: RMCharacterEpisodeCollectionViewCell.self, for: indexPath)
            cell.configure(with: viewModels[indexPath.row])
            cell.backgroundColor = .systemPink
            return cell
        }
    }
    
    private func dequeueCell<T>(in collectionView: UICollectionView, of type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(T.self, indexPath: indexPath) else {
            fatalError()
        }
        return cell
    }
}
