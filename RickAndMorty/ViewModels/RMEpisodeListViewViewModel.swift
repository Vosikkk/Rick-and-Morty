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
            for episode in episodes {
                let vm = RMCharacterEpisodeCollectionViewCellViewModel(
                    episodeDataURL: URL(string: episode.url), 
                    service: service,
                    borderColor: borderColors.randomElement() ?? .systemBlue
                )
                if !cellViewModels.contains(vm) {
                    cellViewModels.append(vm)
                }
            }
        }
    }
    
    private var cellViewModels: [RMCharacterEpisodeCollectionViewCellViewModel] = []
    
    private var apiInfo: RMGetEpisodesResponse.Info? = nil
    
    private var isLoadingMoreEpisodes: Bool = false
    
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
                let res = responseModel.results
                let info = responseModel.info
                self?.apiInfo = info
                self?.episodes = res
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialEpisodes()
                }
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
                let moreRes = responseModel.results
                let info = responseModel.info
                apiInfo = info
                
                let originalCount = episodes.count
                let newCount = moreRes.count
                let total = originalCount + newCount
                let startingIndex = total - newCount
                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex + newCount))
                    .compactMap { IndexPath(row: $0, section: 0) }
                
                episodes.append(contentsOf: moreRes)
                
                DispatchQueue.main.async {
                    self.delegate?.didLoadMoreEpisodes(with: indexPathsToAdd)
                    self.isLoadingMoreEpisodes = false
                }
            case .failure(let failure):
                print(String(describing: failure))
                isLoadingMoreEpisodes = false
            }
        }
    }
}


// MARK: - UICollectionViewDataSource

extension RMEpisodeListViewViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(RMCharacterEpisodeCollectionViewCell.self, indexPath: indexPath) else { fatalError("Unsupported cell") }
       
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

extension RMEpisodeListViewViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelectEpisode(episodes[indexPath.row])
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension RMEpisodeListViewViewModel: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
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
