//
//  RMLocationTableViewCell.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 30.06.2024.
//

import UIKit


final class RMLocationTableViewCell: UITableViewCell {

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(
            ofSize: Constants.NameLabel.fontSize,
            weight: .medium
        )
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(
            ofSize: Constants.TypeLabel.fontSize,
            weight: .regular
        )
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dimensionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(
            ofSize: Constants.DimensionLabel.fontSize,
            weight: .light
        )
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Init
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(nameLabel, typeLabel, dimensionLabel)
        setConstraints()
        accessoryType = .disclosureIndicator
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        typeLabel.text = nil
        dimensionLabel.text = nil
    }
    
    public func configure(with vm: RMLocationTableViewCellViewModel) {
        nameLabel.text = vm.name
        typeLabel.text = vm.type
        dimensionLabel.text = vm.dimension
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.NameLabel.topOffset
            ),
            nameLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: Constants.NameLabel.leftOffset
            ),
            nameLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: Constants.NameLabel.rightOffset
            ),
            typeLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: Constants.TypeLabel.topOffset
            ),
            typeLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: Constants.TypeLabel.leftOffset
            ),
            typeLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: Constants.TypeLabel.rightOffset
            ),
            dimensionLabel.topAnchor.constraint(
                equalTo: typeLabel.bottomAnchor,
                constant: Constants.DimensionLabel.topOffset
            ),
            dimensionLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: Constants.DimensionLabel.leftOffset
            ),
            dimensionLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: Constants.DimensionLabel.rightOffset
            ),
            dimensionLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: Constants.DimensionLabel.bottomOffset
            )
        ])
    }
}


private extension RMLocationTableViewCell {
    
    struct Constants {
        
        struct NameLabel {
            static let fontSize: CGFloat = 20
            static let rightOffset: CGFloat = -10
            static let leftOffset: CGFloat = 10
            static let topOffset: CGFloat = 10
        }
        
        struct TypeLabel {
            static let fontSize: CGFloat = 15
            static let rightOffset: CGFloat = -10
            static let leftOffset: CGFloat = 10
            static let topOffset: CGFloat = 10
        }
        
        struct DimensionLabel {
            static let fontSize: CGFloat = 15
            static let rightOffset: CGFloat = -10
            static let leftOffset: CGFloat = 10
            static let topOffset: CGFloat = 10
            static let bottomOffset: CGFloat = -10
        }
    }
}
