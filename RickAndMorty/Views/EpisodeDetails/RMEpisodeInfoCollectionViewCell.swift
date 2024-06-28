//
//  RMEpisodeInfoCollectionViewCell.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 28.06.2024.
//

import UIKit

final class RMEpisodeInfoCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: Constants.TitleLabel.font,
            weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 0
        label.font = .systemFont(
            ofSize: Constants.ValueLabel.font,
            weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(titleLabel, valueLabel)
        setupLayer()
        setConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueLabel.text = nil
    }
    
    public func configure(with vm: RMEpisodeInfoCollectionViewCellViewModel) {
        titleLabel.text = vm.title
        valueLabel.text = vm.value
    }
    
    private func setupLayer() {
        layer.cornerRadius = Constants.Layer.cornerRadius
        layer.masksToBounds = true
        layer.borderWidth =  Constants.Layer.borderWidth
        layer.borderColor = UIColor.secondaryLabel.cgColor
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.TitleLabel.topOffset
            ),
            titleLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: Constants.TitleLabel.leftOffset
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: Constants.TitleLabel.bottomOffset
            ),
            
            valueLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.ValueLabel.topOffset
            ),
            valueLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: Constants.ValueLabel.rightOffset
            ),
            valueLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: Constants.ValueLabel.bottomOffset
            ),
            
            titleLabel.widthAnchor.constraint(
                equalTo: contentView.widthAnchor,
                multiplier: Constants.multiplier
            ),
            valueLabel.widthAnchor.constraint(
                equalTo: contentView.widthAnchor,
                multiplier: Constants.multiplier
            )
        ])
    }
}

private extension RMEpisodeInfoCollectionViewCell {
    
    struct Constants {
        
        static let multiplier: CGFloat = 0.47
        
        struct Layer {
            static let cornerRadius: CGFloat = 8
            static let borderWidth: CGFloat = 1
        }
        
        struct TitleLabel {
            static let font: CGFloat = 20
            static let topOffset: CGFloat = 4
            static let leftOffset: CGFloat = 8
            static let bottomOffset: CGFloat = -4
        }
        
        struct ValueLabel {
            static let font: CGFloat = 20
            static let topOffset: CGFloat = 4
            static let rightOffset: CGFloat = -8
            static let bottomOffset: CGFloat = -4
        }
    }
}
