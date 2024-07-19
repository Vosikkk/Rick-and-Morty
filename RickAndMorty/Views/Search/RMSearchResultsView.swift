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
    
    func rmSearchResultsView(
        _ sender: RMSearchResultsView,
        didTapCharacterAt index: Int
    )
    
    func rmSearchResultsView(
        _ sender: RMSearchResultsView,
        didTapEpisodeAt index: Int
    )
}

/// Shows search results UI (table or collection as needed)
final class RMSearchResultsView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: RMSearchResultsViewDelegate?
    
    
    private(set) var searchVM: RMSearchResultViewModel? {
        didSet {
            if searchVM?.data.first is RMLocationTableViewCellViewModel {
                setupTableView()
            } else {
                setupCollectionView()
            }
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
    
    
    // MARK: - Public methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    public func configure(vm: RMSearchResultViewModel) {
        searchVM = vm
    }
    
    private var indexPaths: [IndexPath] = []
    
    // MARK: - Private methods
    
    private func setupCollectionView() {
        tableView.isHidden = true
        collectionView.isHidden = false
        setupCollectionViewDelegates()
        collectionView.reloadData()
    }
    
    private func setupTableView() {
        setupTableViewDelegates()
        tableView.isHidden = false
        collectionView.isHidden = true
        tableView.reloadData()
    }
    
    
    private func setupCollectionViewDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
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
    
    // MARK: - Helpers
    
    private var isTableView: Bool {
        tableView.isHidden == false
    }
}

// MARK: - UIScrollViewDelegate

extension RMSearchResultsView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let searchVM,
        !searchVM.data.isEmpty,
        !searchVM.isLoadingMoreResults else { return }
        
        handlePagination(
            scrollView: scrollView,
            searchResVM: searchVM
        )
    }
    
    private func handlePagination(
        scrollView: UIScrollView,
        searchResVM: RMSearchResultViewModel
    ) {
        
        Timer.scheduledTimer(
            withTimeInterval: 0.2,
            repeats: false
        ) { [weak self] t in
            
            guard let self else { return }
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollHeight = scrollView.frame.size.height
            
            if offset >= totalContentHeight - totalScrollHeight - scrollInset {
                searchResVM.fetchAdditionalResults { indexPaths in
                    if self.isTableView {
                        self.updateTable(
                            shouldShowIndicator: searchResVM.shouldShowLoadIndicator
                        )
                    } else {
                        self.updateCollection(with: indexPaths)
                    }
                }
            }
            t.invalidate()
        }
    }
    
    
    
    // MARK: - Helpers 
    
    private func updateTable(shouldShowIndicator: Bool) {
        if shouldShowIndicator {
            self.showTableLoadingIndicator()
        } else {
           tableView.tableFooterView = nil
        }
        tableView.reloadData()
    }
    
    private func updateCollection(with indexPaths: [IndexPath]) {
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
        }
    }
    
    private var scrollInset: CGFloat { 120 }
    
    private func showTableLoadingIndicator() {
        let footer = RMTableLoadingFooterView()
        footer.frame = CGRect(
            x: 0,
            y: 0,
            width: frame.size.width,
            height: Constants.tableFooterHeight
        )
        tableView.tableFooterView = footer
    }
}



// MARK: - Constants

private extension RMSearchResultsView {
    
    struct Constants {
        
        static let tableFooterHeight: CGFloat = 100
        
        struct Collection {
            static let right: CGFloat = 10
            static let left: CGFloat = 10
            static let top: CGFloat = 0
            static let bottom: CGFloat = 10
        }
    }
}
