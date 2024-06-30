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


private extension RMLocationView {
    
    struct Constants {
        static let duration: TimeInterval = 0.3
        
        struct Spinner {
            static let height: CGFloat = 100
            static let width: CGFloat = 100
        }
    }
}
