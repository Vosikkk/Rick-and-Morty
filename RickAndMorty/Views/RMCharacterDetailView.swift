//
//  RMCharacterDetailView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 23.06.2024.
//

import UIKit

/// View for single character info
final class RMCharacterDetailView: UIView {

    private var collectionView: UICollectionView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBlue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        
    }
    
    private func createCollectionView() -> UICollectionView {
        
    }
    
}
