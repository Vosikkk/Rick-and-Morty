//
//  CharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import UIKit

final class CharacterListViewViewModel: NSObject {
   

    func fetchCharacters() {
        RMService().execute(RMRequest(endpoint: .character), expecting: RMGetCharactersResponse.self) { res in
            switch res {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
}


// MARK: - UICollectionViewDataSource
extension CharacterListViewViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemGreen
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CharacterListViewViewModel: UICollectionViewDelegate {
    
}


// MARK: - UICollectionViewDelegateFlowLayout
extension CharacterListViewViewModel: UICollectionViewDelegateFlowLayout {
    
    private var bounds: CGRect {
        UIScreen.main.bounds
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (bounds.width - 30) / 2
        
        return CGSize(
            width: width ,
            height: width * 1.5
        )
    }
}
