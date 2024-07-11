//
//  Extensions+RMSearchResultsView+TableView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 05.07.2024.
//

import UIKit


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
        cellViewModels.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        if let vm = cellViewModels[indexPath.row] as? RMLocationTableViewCellViewModel,
            let cell = tableView.dequeueReusableCell(
            RMLocationTableViewCell.self,
            for: indexPath) {
            
            cell.configure(with: vm)
            return cell
            
        } else {
            fatalError("Failed to dequeue RMLocationTableViewCell")
        }
    }
}
