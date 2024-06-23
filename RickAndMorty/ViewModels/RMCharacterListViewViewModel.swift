//
//  RMCharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import UIKit


protocol RMCharacterListViewViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
    func didLoadMoreCharacters(with newIndexPaths: [IndexPath])
    func didSelectCharacter(_ character: RMCharacter)
}


///  View Model to handle character list view logic
final class RMCharacterListViewViewModel: NSObject {
   
    public weak var delegate: RMCharacterListViewViewModelDelegate? 
    
    public var shouldShowLoadIndicator: Bool {
        apiInfo?.next != nil 
    }
    
    private let service: Service
    
    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters {
                let vm = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    characterImageUrl: URL(string: character.image)
                )
                if !cellViewModels.contains(vm) {
                    cellViewModels.append(vm)
                }
            }
        }
    }
    
    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    
    private var apiInfo: RMGetCharactersResponse.Info? = nil
    
    private var isLoadingMoreCharacters: Bool = false
    
    init(service: Service) {
        self.service = service
    }
    
    
    ///  Fetch initial set of characters (20)
    public func fetchCharacters() {
        service.execute(RMRequest(endpoint: .character), expecting: RMGetCharactersResponse.self) { [weak self] res in
            switch res {
            case .success(let responseModel):
                let res = responseModel.results
                let info = responseModel.info
                self?.apiInfo = info
                self?.characters = res
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialCharacters()
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    /// Paginate if additional characters are needed
    public func fetchAdditionalCharacters(url: URL) {
        guard !isLoadingMoreCharacters else { return }
        
        isLoadingMoreCharacters = true
       
        guard let request = RMRequest(url: url) else {
            isLoadingMoreCharacters = false
            return
        }
        
        service.execute(request, expecting: RMGetCharactersResponse.self) { [weak self] res in
            guard let self else { return }
            switch res {
            case .success(let responseModel):
                let moreRes = responseModel.results
                let info = responseModel.info
                apiInfo = info
                
                let originalCount = characters.count
                let newCount = moreRes.count
                let total = originalCount + newCount
                let startingIndex = total - newCount
                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex + newCount))
                    .compactMap { IndexPath(row: $0, section: 0) }
                
                characters.append(contentsOf: moreRes)
                
                DispatchQueue.main.async {
                    self.delegate?.didLoadMoreCharacters(with: indexPathsToAdd)
                    self.isLoadingMoreCharacters = false
                }
            case .failure(let failure):
                print(String(describing: failure))
                isLoadingMoreCharacters = false
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let footer = collectionView.dequeueReusableSupplementaryView(
                 ofKind: kind,
                 withReuseIdentifier: RMFooterLoaderCollectionReusableView.identifier,
                 for: indexPath
             ) as? RMFooterLoaderCollectionReusableView else {
             fatalError("Unsupported")
        }
        footer.startAnimating()
        
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowLoadIndicator else { return .zero }
        return CGSize(width: collectionView.frame.width, height: footerHeight)
    }
    
    private var footerHeight: Double { 100 }
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

extension RMCharacterListViewViewModel: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadIndicator,
              !isLoadingMoreCharacters,
              !cellViewModels.isEmpty,
              let nextURLString = apiInfo?.next,
              let url = URL(string: nextURLString) else { return }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            guard let self else { return }
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollHeight = scrollView.frame.size.height
            
            if offset >= totalContentHeight - totalScrollHeight - scrollInset {
                fetchAdditionalCharacters(url: url)
            }
            t.invalidate()
        }
    }
    
    private var scrollInset: CGFloat { 120 }
}
