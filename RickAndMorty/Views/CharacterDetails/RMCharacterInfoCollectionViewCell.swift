//
//  RMCharacterInfoCollectionViewCell.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 25.06.2024.
//

import UIKit

final class RMCharacterInfoCollectionViewCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure(with vm: RMCharacterInfoCollectionViewCellViewModel) {
        
    }
    
    private func setConstraints() {
        
    }
    
    
    
}
