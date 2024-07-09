//
//  Extensions+RMSearchResultsView+CollectionView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 05.07.2024.
//

import UIKit

// MARK: - UICollectionViewDataSource

extension RMSearchResultsView: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        collectionViewCellViewModels.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let viewModel = collectionViewCellViewModels[indexPath.row]
        
        if let characterVM = viewModel as? 
            RMCharacterCollectionViewCellViewModel {
            
            let cell = dequeueCell(
                in: collectionView,
                of: RMCharacterCollectionViewCell.self,
                for: indexPath
            )
            cell.configure(with: characterVM)
            return cell
            
        } else if let episodesVM = viewModel as? 
                    RMCharacterEpisodeCollectionViewCellViewModel {
            
            let cell = dequeueCell(
                in: collectionView,
                of: RMCharacterEpisodeCollectionViewCell.self,
                for: indexPath
            )
            cell.configure(with: episodesVM)
            return cell
            
        } else {
            return UICollectionViewCell()
        }
    }
    
    private func dequeueCell<T>(
        in collectionView: UICollectionView,
        of type: T.Type,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = collectionView.dequeueReusableCell(
            T.self,
            indexPath: indexPath
        ) else {
            fatalError("Unsupported cell")
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension RMSearchResultsView: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RMSearchResultsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let viewModel = collectionViewCellViewModels[indexPath.row]
        
        if viewModel is RMCharacterCollectionViewCellViewModel {
            return CGSize(
                width: characterWidth,
                height: characterHeight
            )
        } else {
            return CGSize(
                width: episodeWidth,
                height: episodeHeight
            )
        }
    }
    
    // MARK: - UI Size Helpers Computed Properties
    
    var episodeWidth: CGFloat {
        collectionView.bounds.width - 20
    }
    
    var episodeHeight: CGFloat { 100 }
    
    var characterWidth: CGFloat {
        (_bounds.width - 30) / 2
    }
    
    var characterHeight: CGFloat {
        characterWidth * 1.5
    }
    
    var _bounds: CGRect {
        collectionView.bounds
    }
}
