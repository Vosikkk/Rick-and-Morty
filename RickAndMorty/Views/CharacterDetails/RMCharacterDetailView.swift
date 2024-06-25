//
//  RMCharacterDetailView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 23.06.2024.
//

import UIKit

/// View for single character info
final class RMCharacterDetailView: UIView {
    
    public var collectionView: UICollectionView?
    
    private let detailVM: RMCharacterDetailViewViewModel
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    
    // MARK: - Init
    init(frame: CGRect, vm: RMCharacterDetailViewViewModel) {
        detailVM = vm
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBlue
        let collectionView = createCollectionView()
        self.collectionView = collectionView
        addSubviews(collectionView, spinner)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            self.createSection(for: sectionIndex)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(RMCharacterPhotoCollectionViewCell.self)
        collectionView.register(RMCharacterInfoCollectionViewCell.self)
        collectionView.register(RMCharacterEpisodeCollectionViewCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    private func createSection(for selectionIndex: Int) -> NSCollectionLayoutSection {
        let sections = detailVM.sections
        switch sections[selectionIndex] {
        case .photo:
            return detailVM.createPhotoSectionLayout()
        case .information:
            return detailVM.createInfoSectionLayout()
        case .episodes:
            return detailVM.createEpisodeSectionLayout()
        }
    }
    
    private func setConstraints() {
        guard let collectionView else { return }
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: spinnerWidth),
            spinner.heightAnchor.constraint(equalToConstant: spinnerHeight),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    // MARK: - Constants
    
    private let spinnerWidth: CGFloat = 100
    private let spinnerHeight: CGFloat = 100
    
}

