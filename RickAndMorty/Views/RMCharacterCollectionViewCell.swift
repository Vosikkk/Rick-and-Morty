//
//  RMCharacterCollectionViewCell.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import UIKit

/// Single cell for character
final class RMCharacterCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "RMCharacterCollectionViewCell"
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(
            ofSize: Constants.FontSize.nameLabel,
            weight: .medium
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(
            ofSize: Constants.FontSize.statusLabel,
            weight: .regular
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(imageView, nameLabel, statusLabel)
        setConstraints()
        setupLayer()
        registerTraitChanges()
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
        statusLabel.text = nil
    }
   
    
    public func configure(with vm: RMCharacterCollectionViewCellViewModel) {
        nameLabel.text = vm.characterName
        statusLabel.text = vm.characterStatusText
        
        vm.fetchImage { [weak self] res in
            switch res {
            case .success(let data):
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self?.imageView.image = image
                }
            case .failure(_):
                break
            }
        }
    }
    
    
    // async approach
    private func asyncFetch(vm: RMCharacterCollectionViewCellViewModel) {
        Task {
            do {
                let image = UIImage(data: try await vm.fetchImageAsync())
                await MainActor.run {
                    imageView.image = image
                }
            } catch {
                print(error)
            }
        }
    }
    
     private func setupLayer() {
        contentView.layer.cornerRadius = Constants.LayerSet.cornerRadiusFirst
        contentView.layer.shadowColor = UIColor.secondaryLabel.cgColor
        contentView.layer.cornerRadius = Constants.LayerSet.cornerRadiusSecond
        contentView.layer.shadowOffset = Constants.LayerSet.offset
        contentView.layer.shadowOpacity = Constants.LayerSet.opacity
    }
    
    private func registerTraitChanges() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { 
            (self: Self, previousTraitCollection: UITraitCollection) in
            self.setupLayer()
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            statusLabel.heightAnchor.constraint(
                equalToConstant: Constants.Size.statusLabelHeight
            ),
            nameLabel.heightAnchor.constraint(
                equalToConstant: Constants.Size.nameLabelHeight
            ),
            
            statusLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: Constants.StatusLabelInsets.left
            ),
            statusLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: Constants.StatusLabelInsets.right
            ),
            
            nameLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: Constants.NameLabelInsets.left
            ),
            nameLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: Constants.NameLabelInsets.right
            ),
            
            statusLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: Constants.StatusLabelInsets.bottom
            ),
            
            nameLabel.bottomAnchor.constraint(equalTo: statusLabel.topAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(
                equalTo: nameLabel.topAnchor,
                constant: Constants.imageViewBottomInset
            )
        ])        
    }
}

private extension RMCharacterCollectionViewCell {
    
    struct Constants {
        
        struct LayerSet {
            static let cornerRadiusFirst: CGFloat = 8
            static let cornerRadiusSecond: CGFloat = 4
            static let offset: CGSize = CGSize(width: -4, height: 4)
            static let opacity: Float = 0.3
        }
        
        static let imageViewBottomInset: CGFloat = -3
        
        struct StatusLabelInsets {
            static let left: CGFloat = 7
            static let right: CGFloat = -7
            static let bottom: CGFloat = -3
        }
        
        struct NameLabelInsets {
            static let left: CGFloat = 7
            static let right: CGFloat = -7
        }
        
        struct Size {
            static let statusLabelHeight: CGFloat = 30
            static let nameLabelHeight: CGFloat = 30
        }
        
        struct FontSize {
            static let nameLabel: CGFloat = 18
            static let statusLabel: CGFloat = 18
        }
    }
}
