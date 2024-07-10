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
    
    func rmSearchView(
        _ sender: RMSearchView,
        didSelectLocation location: RMLocation
    )
}

final class RMSearchView: UIView {
    
    weak var delegate: RMSearchViewDelegate?
    
    private let searchVM: RMSearchViewViewModel
    
    // MARK: - Subviews
    
    private let noResultsView: RMNoSearchResultsView
    
    private let searchInputView: RMSearchInputView
    
    private let resultsView: RMSearchResultsView
    
    // MARK: - Init
    
    init(frame: CGRect = .zero, vm: RMSearchViewViewModel) {
        searchVM = vm
        searchInputView = RMSearchInputView()
        noResultsView = RMNoSearchResultsView()
        resultsView = RMSearchResultsView()
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(noResultsView, searchInputView, resultsView)
        setConstraints()
        
        searchInputView.configure(with: .init(with: searchVM.configType))
        searchInputView.delegate = self
        resultsView.delegate = self 
       
        setupHandlers()
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func presentKeyboard() {
        searchInputView.presentKeyboard()
    }
    
    public func didChangeScreenTransition() {
        resultsView.layoutSubviews()
    }
    
    
    private func setupHandlers() {
        searchVM.registerOptionChange { options in
            self.searchInputView.update(with: options.0, and: options.1)
        }
        searchVM.registerSearchResultsHandler { [weak self] result in
            DispatchQueue.main.async {
                self?.resultsView.configure(with: result)
                self?.noResultsView.isHidden = true
                self?.resultsView.isHidden = false
            }
        }
        
        searchVM.registerNoResultsHandler { [weak self] in
            DispatchQueue.main.async {
                self?.noResultsView.isHidden = false
                self?.resultsView.isHidden = true
            }
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // Search Input
            searchInputView.topAnchor.constraint(equalTo: topAnchor),
            searchInputView.leftAnchor.constraint(equalTo: leftAnchor),
            searchInputView.rightAnchor.constraint(equalTo: rightAnchor),
            searchInputView.heightAnchor.constraint(
                equalToConstant: height),
            
            resultsView.topAnchor.constraint(equalTo: searchInputView.bottomAnchor),
            resultsView.leftAnchor.constraint(equalTo: leftAnchor),
            resultsView.rightAnchor.constraint(equalTo: rightAnchor),
            resultsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
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
    
    func rmSearchInputViewDidTapKeyboardSearch(_ sender: RMSearchInputView) {
        searchVM.executeSearch()
    }
    
    func rmSearchInputView(
        _ sender: RMSearchInputView,
        didChangeSearchText text: String
    ) {
        searchVM.set(query: text)
    }
    
    func rmSearchInputView(
        _ sender: RMSearchInputView,
        didSelectOption option: RMSearchInputViewViewModel.DynamicOption
    ) {
        delegate?.rmSearchView(self, didSelectOption: option)
    }
}

extension RMSearchView: RMSearchResultsViewDelegate {
    func rmSearchResultsView(
        _ sender: RMSearchResultsView,
        didTapLocationAt index: Int
    ) {
        guard let locationModel = searchVM.locationSearchResult(at: index) else { return }
        delegate?.rmSearchView(self, didSelectLocation: locationModel)
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
