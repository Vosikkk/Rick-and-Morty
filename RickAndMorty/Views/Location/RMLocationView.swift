//
//  RMLocationView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 29.06.2024.
//

import UIKit


protocol RMLocationViewDelegate: AnyObject {
    func rmLocationView(
        _ locationView: RMLocationView,
        didSelect location: RMLocation
    )
}


final class RMLocationView: UIView {

    public weak var delegate: RMLocationViewDelegate?
    
    private var locationVM: RMLocationViewViewModel? {
        didSet {
            spinner.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            UIView.animate(withDuration: Constants.duration) {
                self.tableView.alpha = 1
            }
            locationVM?.registerDidFinishPaginationBlock { [weak self] in
                self?.tableView.tableFooterView = nil
                self?.tableView.reloadData()
            }
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.alpha = 0
        table.isHidden = true
        table.register(RMLocationTableViewCell.self)
        return table
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(tableView, spinner)
        spinner.startAnimating()
        setConstraints()
        configureTableView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func configure(with vm: RMLocationViewViewModel) {
        locationVM = vm
    }
    
    
    private func showLoadingIndicator() {
        let footer = RMTableLoadingFooterView()
        footer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 100)
        tableView.tableFooterView = footer
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            spinner.heightAnchor.constraint(
                equalToConstant: Constants.Spinner.height
            ),
            spinner.widthAnchor.constraint(
                equalToConstant: Constants.Spinner.width
            ),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
        
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension RMLocationView: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        locationVM?.cellViewModels.count ?? 0
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cellVMs = locationVM?.cellViewModels else {
            fatalError()
        }
        guard let cell = tableView.dequeueReusableCell(
            RMLocationTableViewCell.self,
            for: indexPath
        ) else { fatalError() }
        
        let vm = cellVMs[indexPath.row]
        cell.configure(with: vm)
        return cell
    }
 }

// MARK: - UITableViewDelegate

extension RMLocationView: UITableViewDelegate {
   
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let location = locationVM?.location(at: indexPath.row) else {
          return
        }
        delegate?.rmLocationView(self, didSelect: location)
    }
}

// MARK: - UIScrollViewDelegate

extension RMLocationView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let locationVM,
              !locationVM.cellViewModels.isEmpty,
              !locationVM.isLoadingMoreLocations else { return }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            guard let self else { return }
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollHeight = scrollView.frame.size.height
            
            if offset >= totalContentHeight - totalScrollHeight - scrollInset {
                if locationVM.shouldShowLoadIndicator {
                    DispatchQueue.main.async {
                        self.showLoadingIndicator()
                    }
                    locationVM.fetchAdditionalLocations()
                }
            }
            t.invalidate()
        }
    }
    private var scrollInset: CGFloat { 120 }
}


// MARK: - Constants

private extension RMLocationView {
    
    struct Constants {
        static let duration: TimeInterval = 0.3
        
        struct Spinner {
            static let height: CGFloat = 100
            static let width: CGFloat = 100
        }
    }
}
