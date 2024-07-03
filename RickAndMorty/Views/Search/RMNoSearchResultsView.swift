//
//  RMNoSearchResultsView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 03.07.2024.
//

import UIKit

final class RMNoSearchResultsView: UIView {
    
    private let vm: RMNoSearchResultsViewViewModel = RMNoSearchResultsViewViewModel()
    
    private let iconImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.tintColor = .systemBlue
        return image
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(
            ofSize: Constants.Label.fontSize,
            weight: .medium
        )
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true 
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(iconImage, label)
        setConstraints()
        configure()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            iconImage.widthAnchor.constraint(equalToConstant: Constants.Icon.width),
            iconImage.heightAnchor.constraint(equalToConstant: Constants.Icon.height),
            iconImage.topAnchor.constraint(equalTo: topAnchor),
            iconImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.topAnchor.constraint(
                equalTo: iconImage.bottomAnchor,
                constant: Constants.Label.topOffset
            )
        ])
    }
    
    private func configure() {
        label.text = vm.title
        iconImage.image = vm.image
    }
}

private extension RMNoSearchResultsView {
    struct Constants {
        
        struct Label {
            static let fontSize: CGFloat = 20
            static let topOffset: CGFloat = 10
        }
        
        struct Icon {
            static let width: CGFloat = 90
            static let height: CGFloat = 90
        }
    }
}
