//
//  RMSearchView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 03.07.2024.
//

import UIKit

final class RMSearchView: UIView {
    
    private let searchVM: RMSearchViewViewModel
    
    
    // MARK: - Init
    
    init(frame: CGRect, vm: RMSearchViewViewModel) {
        searchVM = vm
        super.init(frame: frame)
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
