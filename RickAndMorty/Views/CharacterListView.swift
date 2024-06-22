//
//  CharacterListView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import UIKit


/// View that handles showing list of characters, loader, etc.
final class CharacterListView: UIView {

    private let vm: CharacterListViewViewModel = CharacterListViewViewModel()
    
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
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collection
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        addSubviews(collectionView, spinner)
        setConstraints()
        
        spinner.startAnimating()
        
        vm.fetchCharacters()
        
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupCollectionView() {
        collectionView.dataSource = vm
        collectionView.delegate = vm 
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.spinner.stopAnimating()
            
            self.collectionView.isHidden = false
            
            UIView.animate(withDuration: 0.4) {
                self.collectionView.alpha = 1
            }
        }
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
            static let bottom: CGFloat = 0
        }
    }
}
