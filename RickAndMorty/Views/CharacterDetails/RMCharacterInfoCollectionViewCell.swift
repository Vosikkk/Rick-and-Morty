//
//  RMCharacterInfoCollectionViewCell.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 25.06.2024.
//

import UIKit

final class RMCharacterInfoCollectionViewCell: UICollectionViewCell {
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(
            ofSize: Constants.ValueLabel.fontSize,
            weight: .light
        )
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .tertiarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.addSubviews(titleContainerView, valueLabel, iconImageView)
        titleContainerView.addSubview(titleLabel)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        valueLabel.text = nil
        titleLabel.text = nil
        iconImageView.image = nil
        iconImageView.tintColor = nil
        titleLabel.textColor = nil 
    }
    
    
    public func configure(with vm: RMCharacterInfoCollectionViewCellViewModel) {
        titleLabel.text = vm.title
        valueLabel.text = vm.displayValue
        iconImageView.image = vm.iconImage
        iconImageView.tintColor = vm.tintColor
        titleLabel.textColor = vm.tintColor
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleContainerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleContainerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            titleContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleContainerView.heightAnchor.constraint(
                equalTo: contentView.heightAnchor,
                multiplier: Constants.multiplier
            ),
            
            titleLabel.leftAnchor.constraint(equalTo: titleContainerView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: titleContainerView.rightAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleContainerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor),
            
            
            iconImageView.heightAnchor.constraint(
                equalToConstant: Constants.Icon.height
            ),
            iconImageView.widthAnchor.constraint(
                equalToConstant: Constants.Icon.width
            ),
            iconImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.Icon.topOffset
            ),
            iconImageView.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: Constants.Icon.leftOffset
            ),
           
            
            valueLabel.leftAnchor.constraint(
                equalTo: iconImageView.rightAnchor,
                constant: Constants.ValueLabel.leftOffset
            ),
            valueLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: Constants.ValueLabel.rightOffset),
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: titleContainerView.topAnchor),
        ])
    }
    
    struct Constants {
        struct Icon {
            static let height: CGFloat = 30
            static let width: CGFloat = 30
            static let topOffset: CGFloat = 35
            static let leftOffset: CGFloat = 20
        }
        
        struct ValueLabel {
            static let fontSize: CGFloat = 22
            static let leftOffset: CGFloat = 10
            static let rightOffset: CGFloat = -10
        }
        
         static let fontSize: CGFloat = 20
         static let multiplier: CGFloat = 0.33
    }
}
