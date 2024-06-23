//
//  RMCharacterListView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import UIKit

protocol RMCharacterListViewDelegate: AnyObject {
    func rmCharacterListView(
        _ characterListView: RMCharacterListView,
        didSelectCharacter character: RMCharacter
    )
}

/// View that handles showing list of characters, loader, etc.
final class RMCharacterListView: UIView {

    public weak var delegate: RMCharacterListViewDelegate?
    
    private let characterListViewModel: RMCharacterListViewViewModel
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(
            top: Constants.Collection.top,
            left: Constants.Collection.left,
            bottom: Constants.Collection.bottom,
            right: Constants.Collection.right
        )
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isHidden = true
        collection.alpha = 0
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(
            RMCharacterCollectionViewCell.self,
            forCellWithReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier
        )
        return collection
    }()
    
    // MARK: - Init
     init(frame: CGRect, service: Service) {
        characterListViewModel = RMCharacterListViewViewModel(service: service)
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        addSubviews(collectionView, spinner)
        setConstraints()
        
        spinner.startAnimating()
        characterListViewModel.delegate = self 
        characterListViewModel.fetchCharacters()
        
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupCollectionView() {
        collectionView.dataSource = characterListViewModel
        collectionView.delegate = characterListViewModel
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: Constants.spinnerWidth),
            spinner.heightAnchor.constraint(equalToConstant: Constants.spinnerHeight),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private struct Constants {
        static let spinnerWidth: CGFloat = 100
        static let spinnerHeight: CGFloat = 100
        
        struct Collection {
            static let right: CGFloat = 10
            static let left: CGFloat = 10
            static let top: CGFloat = 0
            static let bottom: CGFloat = 10
        }
    }
}


extension RMCharacterListView: RMCharacterListViewViewModelDelegate {
    
    func didSelectCharacter(_ character: RMCharacter) {
        delegate?.rmCharacterListView(self, didSelectCharacter: character)
    }
    
    
    func didLoadInitialCharacters() {
        spinner.stopAnimating()
        collectionView.isHidden = false
        collectionView.reloadData() // Initial fetch 
        UIView.animate(withDuration: 0.4) {
            self.collectionView.alpha = 1
        }
    }
}
