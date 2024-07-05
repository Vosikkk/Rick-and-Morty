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
    
    private var searchVM: RMSearchResultViewModel? {
        didSet {
            processSearchViewModel()
        }
    }
    
    private var locationCellViewModels: [RMLocationTableViewCellViewModel] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(RMLocationTableViewCell.self)
        table.isHidden = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        addSubviews(tableView)
        translatesAutoresizingMaskIntoConstraints = false
        setConstraints()
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func processSearchViewModel() {
        guard let searchVM else { return }
        switch searchVM {
        case .characters(let vms):
            setupCollectionView()
        case .locations(let vms):
            setupTableView(with: vms)
        case .episodes(let vms):
            setupCollectionView()
        }
    }
    
    private func setupCollectionView() {
        
    }
    
    private func setupTableView(with vms: [RMLocationTableViewCellViewModel]) {
        locationCellViewModels = vms
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
        ])
    }
    
    public func configure(with vm: RMSearchResultViewModel) {
        searchVM = vm
    }
}

// MARK: - UITableViewDelegate

extension RMSearchResultsView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.rmSearchResultsView(self, didTapLocationAt: indexPath.row)
    }
}

// MARK: - UITableViewDataSource

extension RMSearchResultsView: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        locationCellViewModels.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            RMLocationTableViewCell.self,
            for: indexPath
        ) else { fatalError("Failed to dequeue RMLocationTableViewCell") }
        cell.configure(with: locationCellViewModels[indexPath.row])
        return cell
    }
}
