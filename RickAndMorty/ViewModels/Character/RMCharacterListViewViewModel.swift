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
   
    
    typealias ViewModel = RMCharacterCollectionViewCellViewModel
    
    // MARK: - Properties
    
    public weak var delegate: RMCharacterListViewViewModelDelegate?
    
    public var shouldShowLoadIndicator: Bool {
        apiInfo?.next != nil 
    }
    
    private let service: Service
    
    private let dataProcessor: DataProcessor<CharacterMapper, RMGetCharactersResponse>
    
    private var calculator: CalculatorIndexPaths
    
    
    private var cellViewModels: [ViewModel] {
        dataProcessor.cellViewModels
    }
    
    private var apiInfo: Info? {
        dataProcessor.apiInfo
    }
    
    private var isLoadingMoreCharacters: Bool = false {
        didSet {
            if isLoadingMoreCharacters,
               calculator._lastIndex != dataProcessor.items.endIndex {
                calculator._lastIndex = dataProcessor.items.endIndex
            }
        }
    }
    
    // MARK: - Init
    
    init(service: Service) {
        self.service = service
        self.dataProcessor = .init(mapper: CharacterMapper(service: service))
        calculator = .init()
    }
    
    
    // MARK: - Public methods
    
    ///  Fetch initial set of characters (20)
    public func fetchCharacters() {
        service.execute(
            RMRequest(endpoint: .character),
            expecting: RMGetCharactersResponse.self
        ) { [weak self] res in
            guard let self else { return }
            
            switch res {
                
            case .success(let responseModel):
                dataProcessor.handleInitial(responseModel)
                
                DispatchQueue.mainAsyncIfNeeded {
                    self.delegate?.didLoadInitialCharacters()
                }
                
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
            case .success(let responseModel):
                
                dataProcessor.handleAdditional(responseModel)
                
                DispatchQueue.mainAsyncIfNeeded {
                    self.delegate?.didLoadMoreCharacters(
                        with: self.calculator.calculateIndexPaths(
                            count: responseModel.results.count
                        )
                    )
                    self.isLoadingMoreCharacters = false
                }
                
            case .failure(let failure):
                print(String(describing: failure))
                isLoadingMoreCharacters = false
            }
        }
    }
    
    // MARK: - Private methods
    
    
    private func character(at index: Int) -> RMCharacter? {
        return dataProcessor.item(at: index)
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
        if let character = character(at: indexPath.row) {
            delegate?.didSelectCharacter(character)
        }
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
