//
//  RMSearchInputView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 03.07.2024.
//

import UIKit

protocol RMSearchInputViewDelegate: AnyObject {
    func rmSearchInputView(
        _ sender: RMSearchInputView,
        didSelectOption option: RMSearchInputViewViewModel.DynamicOption
    )
    
    func rmSearchInputView(
        _ sender: RMSearchInputView,
        didChangeSearchText text: String
    )
    
    func rmSearchInputViewDidTapKeyboardSearch(
        _ sender: RMSearchInputView
     )
}

/// View for top part of search screen with search bar 
final class RMSearchInputView: UIView {

    typealias Option = RMSearchInputViewViewModel.DynamicOption

    weak var delegate: RMSearchInputViewDelegate?
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search"
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private var inputViewVM: RMSearchInputViewViewModel? {
        didSet {
            guard let inputViewVM,
                    inputViewVM.hasDynamicOptions
            else {
                return
            }
            createOptionSelectionViews(
                with: inputViewVM.options
            )
        }
    }
    
    private var stackView: UIStackView?
    
    // MARK: - Init
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(searchBar)
        setConstraints()
        
        searchBar.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public func presentKeyboard() {
        searchBar.becomeFirstResponder()
    }
    
    public func configure(with vm: RMSearchInputViewViewModel) {
        searchBar.placeholder = vm.searchPlaceholderText
        inputViewVM = vm 
    }
    
    public func update(with option: Option, and newTitle: String) {
        guard let buttons = stackView?.arrangedSubviews as? [UIButton],
              let options = inputViewVM?.options,
              let index = options.firstIndex(of: option) else { return }
        
        buttons[index].setAttributedTitle(
            attrubitedString(
                newTitle.uppercased(),
                color: UIColor.link
            ),
            for: .normal
        )
    }
    
    
    // MARK: - Private
    
    private func createOptionSelectionViews(with options: [Option]) {
        let stackView = createOptionStackView()
        options.enumerated().forEach { index, option in
            stackView.addArrangedSubview(createButton(for: option, tag: index))
        }
    }
    
    private func createButton(for option: Option, tag: Int) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .secondarySystemFill
        button.addTarget(
            self,
            action: #selector(didTapButton(_:)),
            for: .touchUpInside
        )
        button.setAttributedTitle(
            attrubitedString(option.rawValue),
            for: .normal
        )
        button.layer.cornerRadius = Constants.Button.cornerRaduis
        button.tag = tag
        return button
    }
    
   
    
    
    private func createOptionStackView() -> UIStackView {
        let stackView = UIStackView()
        self.stackView = stackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = Constants.stackSpacing
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        return stackView
    }
    
    private func attrubitedString(
        _ string: String,
        fontSize: CGFloat = Constants.Button.fontSize,
        color: UIColor = UIColor.label
    ) -> NSAttributedString {
        
        let font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        return NSAttributedString(string: string, attributes: [
            .foregroundColor: color,
            .font: font]
        )
    }
    
    @objc
    private func didTapButton(_ sender: UIButton) {
        guard let options = inputViewVM?.options else { return }
        delegate?.rmSearchInputView(self, didSelectOption: options[sender.tag])
    }

    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leftAnchor.constraint(equalTo: leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: rightAnchor),
            searchBar.heightAnchor.constraint(
                equalToConstant: Constants.SearchBar.height
            ),
        ])
    }
}

// MARK: - UISearchBarDelegate

extension RMSearchInputView: UISearchBarDelegate {
    
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        delegate?.rmSearchInputView(
            self, didChangeSearchText: searchText
        )
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        delegate?.rmSearchInputViewDidTapKeyboardSearch(self)
    }
}

// MARK: - Constants

private extension RMSearchInputView {
    
    struct Constants {
        
        static let stackSpacing: CGFloat = 6
        
        struct Button {
            static let fontSize: CGFloat = 18
            static let cornerRaduis: CGFloat = 6
        }
        
        struct SearchBar {
            static let height: CGFloat = 58
        }
    }
}
