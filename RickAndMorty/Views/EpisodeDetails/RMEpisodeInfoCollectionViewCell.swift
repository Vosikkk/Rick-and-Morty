//
//  RMEpisodeInfoCollectionViewCell.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 28.06.2024.
//

import UIKit

final class RMEpisodeInfoCollectionViewCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        setupLayer()
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure(with vm: RMEpisodeInfoCollectionViewCellViewModel) {
        
    }
    
    private func setupLayer() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        layer.borderWidth = borderWidth
        layer.borderColor = UIColor.secondaryLabel.cgColor
    }
    
    
    private let cornerRadius: CGFloat = 8
    private let borderWidth: CGFloat = 1
}
