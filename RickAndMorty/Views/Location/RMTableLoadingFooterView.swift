//
//  RMTableLoadingFooterView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 09.07.2024.
//

import UIKit

final class RMTableLoadingFooterView: UIView {

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
        spinner.startAnimating()
        
        setConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: Constants.width),
            spinner.heightAnchor.constraint(equalToConstant: Constants.height),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

private extension RMTableLoadingFooterView {
    
    var screenWidth: CGFloat {
       UIScreen.main.bounds.width
   }
    
    struct Constants {
        static let width: CGFloat = 55
        static let height: CGFloat = 55
        
        static let viewHeight: CGFloat = 100
    }
}
