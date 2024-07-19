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
   
    // MARK: - Properties
    
    public weak var delegate: RMCharacterListViewViewModelDelegate?
    
    public var shouldShowLoadIndicator: Bool {
        apiInfo?.next != nil 
    }
    
    private let service: Service
    
    private var calculator: CalculatorIndexPaths
    
    private var characters: [RMCharacter] = [] {
        didSet {
            cellViewModels.append(
                contentsOf: createViewModels(
                    from: characters, 
                    startingAt: calculator._lastIndex
                )
            )
        }
    }
    
    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    
    private var apiInfo: Info? = nil
    
    private var isLoadingMoreCharacters: Bool = false {
        didSet {
            if isLoadingMoreCharacters,
                calculator._lastIndex != characters.endIndex {
                calculator._lastIndex = characters.endIndex
            }
        }
    }
    
    // MARK: - Init
    
    init(service: Service) {
        self.service = service
        calculator = .init()
    }
    
    
    // MARK: - Public methods
    
    ///  Fetch initial set of characters (20)
    public func fetchCharacters() {
        service.execute(
            RMRequest(endpoint: .character),
            expecting: RMGetCharactersResponse.self
        ) { [weak self] res in
            
            switch res {
            case .success(let model):
                self?.handleInitial(response: model)
            case .failure(let failure):
                print(String(describing: failure))
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
        
        service.execute(
            request,
            expecting: RMGetCharactersResponse.self
        ) { [weak self] res in
            
            guard let self else { return }
            switch res {
            case .success(let model):
                handleAdditional(response: model)
            case .failure(let failure):
                print(String(describing: failure))
                isLoadingMoreCharacters = false
            }
        }
    }
    
    // MARK: - Private methods
    
    private func handleInitial(response: RMGetCharactersResponse) {
        apiInfo = response.info
        characters = response.results
        DispatchQueue.mainAsyncIfNeeded { [weak self] in
            self?.delegate?.didLoadInitialCharacters()
        }
    }
    
    private func handleAdditional(response: RMGetCharactersResponse) {
        apiInfo = response.info
        characters.append(contentsOf: response.results)
        
        DispatchQueue.mainAsyncIfNeeded { [weak self] in
            guard let self else { return }
            delegate?.didLoadMoreCharacters(
                with: calculator.calculateIndexPaths(
                    count: response.results.count
                )
            )
            isLoadingMoreCharacters = false
        }
    }
    
    private func createViewModels(
        from characters: [RMCharacter],
        startingAt index: Int
    ) -> [RMCharacterCollectionViewCellViewModel] {
        
        return characters[index...]
            .map {
                .init(
                    characterName: $0.name,
                    characterStatus: $0.status,
                    characterImageUrl: URL(string: $0.image),
                    service: service
                )
            }
    }
}


// MARK: - UICollectionViewDataSource

extension RMCharacterListViewViewModel: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        cellViewModels.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            RMCharacterCollectionViewCell.self,
            indexPath: indexPath
        ) else { fatalError("Unsupported cell") }
       
        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
       
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
       
        return shouldShowLoadIndicator ? CGSize(
            width: collectionView.frame.width,
            height: footerHeight
        ) : .zero
    }
    
    private var footerHeight: Double { 100 }
}

// MARK: - UICollectionViewDelegate

extension RMCharacterListViewViewModel: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelectCharacter(characters[indexPath.row])
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension RMCharacterListViewViewModel: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
       
        let width: CGFloat = UIDevice.isiPhone ?
        (collectionView.bounds.width - 30) / 2 :
        (collectionView.bounds.width - 50) / 4
       
        return CGSize(
            width: width,
            height: width * 1.5
        )
    }
}

// MARK: - UIScrollViewDelegate

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
