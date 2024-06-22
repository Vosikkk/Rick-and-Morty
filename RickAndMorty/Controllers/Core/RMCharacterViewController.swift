//
//  RMCharacterViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import UIKit

/// Controller to show and search for Characters
final class RMCharacterViewController: UIViewController {

    
    private let charactersListView: CharacterListView = CharacterListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(charactersListView)
        NSLayoutConstraint.activate([
            charactersListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            charactersListView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Constants.leftOffset),
            charactersListView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constants.rightOffset),
            charactersListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    
    private struct Constants {
        static let leftOffset: CGFloat = 0
        static let rightOffset: CGFloat = 0
    }
}
