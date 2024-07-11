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
    
    private(set) var searchResVM: RMSearchResultViewModel? {
        didSet {
            processSearchViewModel()
        }
    }
    
    private(set) var cellViewModels: [any Hashable] = []
        
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
    
    public func configure(with vm: RMSearchResultViewModel) {
        searchResVM = vm
    }
    
    private func processSearchViewModel() {
        guard let searchResVM else { return }
        switch searchResVM.results {
        case .characters(let vms):
            setupCollectionView(with: vms)
        case .locations(let vms):
            setupTableView(with: vms)
        case .episodes(let vms):
            setupCollectionView(with: vms)
        }
    }
    
    private func setupCollectionView(with vms: [any Hashable]) {
        cellViewModels = vms
        tableView.isHidden = true
        collectionView.isHidden = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.reloadData()
    }
    
    private func setupTableView(with vms: [any Hashable]) {
        cellViewModels = vms
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
    
    private var isTableView: Bool {
        tableView.isHidden == false
    }
    
    private var lastIndex: Int = 0
}

// MARK: - UIScrollViewDelegate

extension RMSearchResultsView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let searchResVM,
        !cellViewModels.isEmpty,
        !searchResVM.isLoadingMoreResults else { return }
        
        handlePagination(scrollView: scrollView, searchResVM: searchResVM)
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
                searchResVM.fetchAdditionalResults { newVms in
                    
                    self.cellViewModels.append(contentsOf: newVms)
                    
                    if self.isTableView {
                        if searchResVM.shouldShowLoadIndicator {
                            DispatchQueue.main.async {
                                self.showTableLoadingIndicator()
                            }
                        }
                        self.updateTable(with: newVms)
                    } else {
                        self.updateCollection(with: newVms)
                    }
                }
                lastIndex = cellViewModels.endIndex
            }
            t.invalidate()
        }
    }
    
    private func updateTable(with newVms: [any Hashable]) {
        tableView.tableFooterView = nil
        tableView.reloadData()
    }
    
    private func updateCollection(with newVms: [any Hashable]) {
        collectionView.performBatchUpdates {
            collectionView.insertItems(
                at: calculateIndexPaths(with: newVms.count)
            )
        }
    }
    
    private func calculateIndexPaths(with newVmsCount: Int) -> [IndexPath] {
        let endIndex = lastIndex + newVmsCount
        return Array(lastIndex..<endIndex).compactMap {
            IndexPath(item: $0, section: 0)
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
