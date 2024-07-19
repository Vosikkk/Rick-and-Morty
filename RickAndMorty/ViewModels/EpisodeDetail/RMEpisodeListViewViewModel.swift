//
//  RMEpisodeListViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 27.06.2024.
//

import UIKit


protocol RMEpisodeListViewViewModelDelegate: AnyObject {
    func didLoadInitialEpisodes()
    func didLoadMoreEpisodes(with newIndexPaths: [IndexPath])
    func didSelectEpisode(_ episode: RMEpisode)
}


///  View Model to handle episode list view logic
final class RMEpisodeListViewViewModel: NSObject {
   
    public weak var delegate: RMEpisodeListViewViewModelDelegate?
    
    public var shouldShowLoadIndicator: Bool {
        apiInfo?.next != nil
    }
    
    private let service: Service
    
    private let borderColors: [UIColor] = [
        .systemGreen,
        .systemBlue,
        .systemOrange,
        .systemPink,
        .systemPurple,
        .systemRed,
        .systemYellow,
        .systemIndigo,
        .systemMint
    ]
    
    private var episodes: [RMEpisode] = [] {
        didSet {
            cellViewModels.append(
                contentsOf: createViewModels(
                    from: episodes,
                    startingAt: calculator._lastIndex
                )
            )
        }
    }
    
    private var cellViewModels: [RMCharacterEpisodeCollectionViewCellViewModel] = []
    
    private var apiInfo: Info? = nil
    
    private var calculator: CalculatorIndexPaths = .init()
    
    private var isLoadingMoreEpisodes: Bool = false {
        didSet {
            if isLoadingMoreEpisodes,
               calculator._lastIndex != episodes.endIndex {
                calculator._lastIndex = episodes.endIndex
            }
        }
    }
    
    init(service: Service) {
        self.service = service
    }
    
    
    ///  Fetch initial set of episodes (20)
    public func fetchEpisodes() {
        service.execute(
            RMRequest(endpoint: .episode),
            expecting: RMGetEpisodesResponse.self
        ) { [weak self] res in
            
            switch res {
            case .success(let responseModel):
                self?.handleInitial(response: responseModel)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    /// Paginate if additional episodes are needed
    public func fetchAdditionalEpisodes(url: URL) {
        guard !isLoadingMoreEpisodes else { return }
        
        isLoadingMoreEpisodes = true
       
        guard let request = RMRequest(url: url) else {
            isLoadingMoreEpisodes = false
            return
        }
        
        service.execute(
            request, expecting:
                RMGetEpisodesResponse.self
        ) { [weak self] res in
            guard let self else { return }
            switch res {
            case .success(let responseModel):
                handleAdditional(response: responseModel)
            case .failure(let failure):
                print(String(describing: failure))
                isLoadingMoreEpisodes = false
            }
        }
    }
    
    private func handleAdditional(response: RMGetEpisodesResponse) {
        apiInfo = response.info
        episodes.append(contentsOf: response.results)
        let indexPathsToAdd = calculator.calculateIndexPaths(count: response.results.count)
        DispatchQueue.mainAsyncIfNeeded{
            self.delegate?.didLoadMoreEpisodes(with: indexPathsToAdd)
            self.isLoadingMoreEpisodes = false
        }
    }
    
    private func handleInitial(response: RMGetEpisodesResponse) {
        apiInfo = response.info
        episodes = response.results
        DispatchQueue.mainAsyncIfNeeded { [weak self] in
            self?.delegate?.didLoadInitialEpisodes()
        }
    }
    
    private func createViewModels(
        from episodes: [RMEpisode],
        startingAt index: Int
    ) -> [RMCharacterEpisodeCollectionViewCellViewModel] {
        return episodes[index...]
            .map {
                .init(
                    episodeDataURL: URL(string: $0.url),
                    service: service,
                    borderColor: borderColors.randomElement() ?? .systemBlue
                )
        }
    }
}


// MARK: - UICollectionViewDataSource

extension RMEpisodeListViewViewModel: UICollectionViewDataSource {
    
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
            RMCharacterEpisodeCollectionViewCell.self,
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
        
        guard shouldShowLoadIndicator else { return .zero }
        return CGSize(width: collectionView.frame.width, height: footerHeight)
    }
    
    private var footerHeight: Double { 100 }
}

// MARK: - UICollectionViewDelegate

extension RMEpisodeListViewViewModel: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelectEpisode(episodes[indexPath.row])
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension RMEpisodeListViewViewModel: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let bounds = collectionView.bounds
        
        let width = bounds.width - 20
        
        return CGSize(
            width: width ,
            height: collectionHeight
        )
    }
    
    private var collectionHeight: CGFloat { 100 }
}

extension RMEpisodeListViewViewModel: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadIndicator,
              !isLoadingMoreEpisodes,
              !cellViewModels.isEmpty,
              let nextURLString = apiInfo?.next,
              let url = URL(string: nextURLString) else { return }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            guard let self else { return }
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollHeight = scrollView.frame.size.height
            
            if offset >= totalContentHeight - totalScrollHeight - scrollInset {
                fetchAdditionalEpisodes(url: url)
            }
            t.invalidate()
        }
    }
    
    private var scrollInset: CGFloat { 120 }
}
