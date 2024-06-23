//
//  RMCharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import UIKit


protocol RMCharacterListViewViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
    func didSelectCharacter(_ character: RMCharacter)
}


final class RMCharacterListViewViewModel: NSObject {
   
    
    public weak var delegate: RMCharacterListViewViewModelDelegate? 
    
    let service: Service
    
    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters {
                let vm = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    characterImageUrl: URL(string: character.image)
                )
                cellViewModels.append(vm)
            }
        }
    }

    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    
    
    init(service: Service) {
        self.service = service
    }
    
    public func fetchCharacters() {
        service.execute(RMRequest(endpoint: .character), expecting: RMGetCharactersResponse.self) { [weak self] res in
            switch res {
            case .success(let responseModel):
                let res = responseModel.results
                self?.characters = res
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialCharacters()
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
}


// MARK: - UICollectionViewDataSource
extension RMCharacterListViewViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier,
            for: indexPath
        ) as? RMCharacterCollectionViewCell else { fatalError("Unsupported cell") }
       
        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension RMCharacterListViewViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelectCharacter(characters[indexPath.row])
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension RMCharacterListViewViewModel: UICollectionViewDelegateFlowLayout {
    
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
