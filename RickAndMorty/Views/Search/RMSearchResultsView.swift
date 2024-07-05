//
//  RMSearchResultsView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 05.07.2024.
//

import UIKit

/// Shows search results UI (table or collection as needed)
final class RMSearchResultsView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setConstraints() {
        
    }
    
    public func configure(with vm: RMSearchResultViewModel) {}
}
