//
//  RMCharacterEpisodeCollectionViewCell.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 25.06.2024.
//

import UIKit

final class RMCharacterEpisodeCollectionViewCell: UICollectionViewCell {
    
    private let seasonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(
            ofSize: Constants.SeasonLabel.fontSize,
            weight: .semibold
        )
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(
            ofSize: Constants.NameLabel.fontSize,
            weight: .regular
        )
        return label
    }()
    
    private let airDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(
            ofSize: Constants.AirDateLabel.fontSize,
            weight: .light
        )
        return label
    }()
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .tertiarySystemBackground
        setupLayer()
        contentView.addSubviews(seasonLabel, nameLabel, airDateLabel)
        setConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        seasonLabel.text = nil
        nameLabel.text = nil
        airDateLabel.text = nil
    }
    
    
    
    public func configure(with vm: RMCharacterEpisodeCollectionViewCellViewModel) {
        vm.registerForData { [weak self] data in
            self?.seasonLabel.text = "Episode "+data.episode
            self?.nameLabel.text = data.name
            self?.airDateLabel.text = "Aired on "+data.air_date
        }
        vm.fetchEpisode()
        contentView.layer.borderColor = vm.borderColor.cgColor
    }
    
    private func setupLayer() {
        contentView.layer.cornerRadius = Constants.CellLayer.cornerRaduis
        contentView.layer.borderWidth = Constants.CellLayer.borderWidth
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            seasonLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            seasonLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: Constants.SeasonLabel.leftOffset
            ),
            seasonLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: Constants.SeasonLabel.rightOffset
            ),
            seasonLabel.heightAnchor.constraint(
                equalTo: contentView.heightAnchor,
                multiplier: Constants.SeasonLabel.multiplier
            ),
            
            nameLabel.topAnchor.constraint(equalTo: seasonLabel.bottomAnchor),
            nameLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: Constants.NameLabel.leftOffset
            ),
            nameLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: Constants.NameLabel.rightOffset
            ),
            nameLabel.heightAnchor.constraint(
                equalTo: contentView.heightAnchor,
                multiplier: Constants.NameLabel.multiplier
            ),
            
            airDateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            airDateLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: Constants.AirDateLabel.leftOffset
            ),
            airDateLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: Constants.AirDateLabel.rightOffset
            ),
            airDateLabel.heightAnchor.constraint(
                equalTo: contentView.heightAnchor,
                multiplier: Constants.AirDateLabel.multiplier
            ),
        ])
    }
}


private extension RMCharacterEpisodeCollectionViewCell {
    
    struct Constants {
        
        struct SeasonLabel {
            static let fontSize: CGFloat = 20
            static let multiplier: CGFloat = 0.3
            static let leftOffset: CGFloat = 10
            static let rightOffset: CGFloat = -10
        }
        
        struct NameLabel {
            static let multiplier: CGFloat = 0.3
            static let fontSize: CGFloat = 22
            static let leftOffset: CGFloat = 10
            static let rightOffset: CGFloat = -10
        }
        
        struct AirDateLabel {
            static let multiplier: CGFloat = 0.3
            static let fontSize: CGFloat = 18
            static let leftOffset: CGFloat = 10
            static let rightOffset: CGFloat = -10
        }
        
        struct CellLayer {
            static let cornerRaduis: CGFloat = 8
            static let borderWidth: CGFloat = 2
        }
    }
}
