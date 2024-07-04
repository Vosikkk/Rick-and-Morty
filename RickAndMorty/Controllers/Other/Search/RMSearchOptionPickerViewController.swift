//
//  RMSearchOptionPickerViewController.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 04.07.2024.
//

import UIKit

final class RMSearchOptionPickerViewController: UIViewController {
    
    typealias Option = RMSearchInputViewViewModel.DynamicOption
    
    private let option: Option
    
    private let selectionBlock: (String) -> Void
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self)
        return table
    }()
    
    
    
    init(_ option: Option, selection: @escaping (String) -> Void) {
        self.option = option
        self.selectionBlock = selection
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate

extension RMSearchOptionPickerViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectionBlock(option.choices[indexPath.row])
        dismiss(animated: true)
        
    }
}

// MARK: - UITableViewDataSource

extension RMSearchOptionPickerViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        option.choices.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            UITableViewCell.self,
            for: indexPath)!
        
        cell.textLabel?.text = option.choices[indexPath.row].uppercased()
        return cell
    }
}
