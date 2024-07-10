//
//  RMSearchResultsView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 05.07.2024.
//

import UIKit


protocol RMSearchResultsViewDelegate: AnyObject {
    func rmSearchResultsView(
        _ sender: RMSearchResultsView,
        didTapLocationAt index: Int
    )
}

/// Shows search results UI (table or collection as needed)
final class RMSearchResultsView: UIView {
    
    weak var delegate: RMSearchResultsViewDelegate?
    
    private var searchResVM: RMSearchResultViewModel? {
        didSet {
            processSearchViewModel()
        }
    }
    
    private(set) var locationCellViewModels: [RMLocationTableViewCellViewModel] = []
    
    private(set) var collectionViewCellViewModels: [any Hashable] = [] {
        didSet {
            setupCollectionView()
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(RMLocationTableViewCell.self)
        table.isHidden = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let collectionView: UICollectionView = {
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
       
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(RMCharacterCollectionViewCell.self)
        collection.register(RMCharacterEpisodeCollectionViewCell.self)
        collection.register(
            RMFooterLoaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: RMFooterLoaderCollectionReusableView.identifier
        )
        return collection
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        addSubviews(tableView, collectionView)
        translatesAutoresizingMaskIntoConstraints = false
        setConstraints()
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    private func processSearchViewModel() {
        guard let searchResVM else { return }
        switch searchResVM.results {
        case .characters(let vms):
            collectionViewCellViewModels = vms
        case .locations(let vms):
            setupTableView(with: vms)
        case .episodes(let vms):
            collectionViewCellViewModels = vms
        }
    }
    
    private func setupCollectionView() {
        tableView.isHidden = true
        collectionView.isHidden = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.reloadData()
    }
    
    private func setupTableView(with vms: [RMLocationTableViewCellViewModel]) {
        locationCellViewModels = vms
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        collectionView.isHidden = true
        tableView.reloadData()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    public func configure(with vm: RMSearchResultViewModel) {
        searchResVM = vm
    }
}

// MARK: - UIScrollViewDelegate

extension RMSearchResultsView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !locationCellViewModels.isEmpty {
            handleLocationPagination(scrollView: scrollView)
        } else {
            handleCharacterOrEpisodePagination(scrollView: scrollView)
        }
    }
    
    private func handleCharacterOrEpisodePagination(scrollView: UIScrollView) {
        
    }
    
    private func handleLocationPagination(scrollView: UIScrollView) {
        guard let searchResVM,
        !locationCellViewModels.isEmpty,
        !searchResVM.isLoadingMoreResults else { return }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            guard let self else { return }
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollHeight = scrollView.frame.size.height
            
            if offset >= totalContentHeight - totalScrollHeight - scrollInset {
                if searchResVM.shouldShowLoadIndicator {
                    DispatchQueue.main.async {
                        self.showLoadingIndicator()
                    }
                    searchResVM.fetchAdditionalLocations { res in
                        self.tableView.tableFooterView = nil
                        self.locationCellViewModels = res
                        self.tableView.reloadData()
                    }
                }
            }
            t.invalidate()
        }
    }
    
    private var scrollInset: CGFloat { 120 }
    
    private func showLoadingIndicator() {
        let footer = RMTableLoadingFooterView()
        footer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 100)
        tableView.tableFooterView = footer
    }
}



// MARK: - Constants

private extension RMSearchResultsView {
    
    struct Constants {
        struct Collection {
            static let right: CGFloat = 10
            static let left: CGFloat = 10
            static let top: CGFloat = 0
            static let bottom: CGFloat = 10
        }
    }
}
