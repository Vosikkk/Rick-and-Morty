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
}

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
            else { return }
            createOptionSelectionViews(with: inputViewVM.options)
        }
    }
    
    // MARK: - Init
    
     override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(searchBar)
        setConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with vm: RMSearchInputViewViewModel) {
        searchBar.placeholder = vm.searchPlaceholderText
        inputViewVM = vm 
    }
    
    
    private func createOptionSelectionViews(with options: [Option]) {
        let stackView = createOptionStackView()
        var tag: Int = 0
        options.forEach {
            let button = UIButton()
            configureButton(button, tag: tag, title: $0.rawValue)
            tag += 1
            stackView.addArrangedSubview(button)
        }
    }
    
    private func configureButton(_ button: UIButton, tag: Int, title: String) {
        button.backgroundColor = .secondarySystemFill
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        button.setAttributedTitle(
            attrubitedString(title),
            for: .normal
        )
        button.layer.cornerRadius = Constants.Button.cornerRaduis
        button.tag = tag
    }
    
    
    private func createOptionStackView() -> UIStackView {
        let stackView = UIStackView()
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
        fontSize: CGFloat = Constants.Button.fontSize
    ) -> NSAttributedString {
        
        let font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        let color = UIColor.label
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
    
    public func presentKeyboard() {
        searchBar.becomeFirstResponder()
    }
}

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
