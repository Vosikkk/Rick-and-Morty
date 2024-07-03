//
//  RMSearchView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 03.07.2024.
//

import UIKit


protocol RMSearchViewDelegate: AnyObject {
    func rmSearchView(
        _ sender: RMSearchView,
        didSelectOption option: RMSearchInputViewViewModel.DynamicOption
    )
}

final class RMSearchView: UIView {
    
    weak var delegate: RMSearchViewDelegate?
    
    private let searchVM: RMSearchViewViewModel
    
    // MARK: - Subviews
    
    private let noResultsView: RMNoSearchResultsView = RMNoSearchResultsView()
    
    private let searchInputView: RMSearchInputView
    
    // MARK: - Init
    
    init(frame: CGRect = .zero, vm: RMSearchViewViewModel) {
        searchVM = vm
        searchInputView = RMSearchInputView()
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(noResultsView, searchInputView)
        setConstraints()
        searchInputView.configure(with: .init(with: searchVM.configType))
        searchInputView.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func presentKeyboard() {
        searchInputView.presentKeyboard()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // Search Input
            searchInputView.topAnchor.constraint(equalTo: topAnchor),
            searchInputView.leftAnchor.constraint(equalTo: leftAnchor),
            searchInputView.rightAnchor.constraint(equalTo: rightAnchor),
            searchInputView.heightAnchor.constraint(
                equalToConstant: height),
            // No results
            noResultsView.widthAnchor.constraint(
                equalToConstant: Constants.NoResultsView.width
            ),
            noResultsView.heightAnchor.constraint(
                equalToConstant: Constants.NoResultsView.height
            ),
            noResultsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultsView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
}

// MARK: - UICollectionViewDelegate

extension RMSearchView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
}

// MARK: - UICollectionViewDataSource

extension RMSearchView: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            UICollectionViewCell.self,
            indexPath: indexPath
        ) else { fatalError() }
        
        return cell
    }
}

// MARK: - RMSearchInputViewDelegate

extension RMSearchView: RMSearchInputViewDelegate {
    func rmSearchInputView(
        _ sender: RMSearchInputView,
        didSelectOption option: RMSearchInputViewViewModel.DynamicOption
    ) {
        delegate?.rmSearchView(self, didSelectOption: option)
    }
}

// MARK: - Constants

private extension RMSearchView {
    
    var height: CGFloat {
        searchVM.configType == .episode ?
        55 : 110
    }
    
    struct Constants {
        
        struct SearchInputView {
            
        }
        
        struct NoResultsView {
            static let width: CGFloat = 150
            static let height: CGFloat = 150
        }
    }
}
