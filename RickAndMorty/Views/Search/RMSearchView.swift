//
//  RMSearchView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 03.07.2024.
//

import UIKit

final class RMSearchView: UIView {
    
    private let searchVM: RMSearchViewViewModel
    
    private let noResultsView: RMNoSearchResultsView = RMNoSearchResultsView()
    
    
    // MARK: - Init
    
    init(frame: CGRect = .zero, vm: RMSearchViewViewModel) {
        searchVM = vm
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(noResultsView)
        setConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            noResultsView.widthAnchor.constraint(
                equalToConstant: Constants.NoResultsView.width
            ),
            noResultsView.heightAnchor.constraint(
                equalToConstant: Constants.NoResultsView.height
            ),
            noResultsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultsView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            
        
        ])
    }
    
}

// MARK: - UICollectionViewDelegate

extension RMSearchView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
}

// MARK: - UICollectionViewDataSource

extension RMSearchView: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            UICollectionViewCell.self,
            indexPath: indexPath
        ) else { fatalError() }
        
        return cell
    }
}

private extension RMSearchView {
    
    struct Constants {
        
        struct NoResultsView {
            static let width: CGFloat = 150
            static let height: CGFloat = 150
        }
    }
}
