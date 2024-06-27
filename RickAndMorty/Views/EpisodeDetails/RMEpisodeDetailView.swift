//
//  RMEpisodeDetailView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 27.06.2024.
//

import UIKit

final class RMEpisodeDetailView: UIView {

    private var episodeDeatilVM: RMEpisodeDetailViewViewModel? {
        didSet {
            spinner.stopAnimating()
            collectionView?.reloadData()
            collectionView?.isHidden = false
            UIView.animate(withDuration: Constants.duration) {
                self.collectionView?.alpha = 1
            }
        }
    }
    
    private var collectionView: UICollectionView?
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false 
        backgroundColor = .systemBackground
        let collectionView = createCollectionView()
        addSubviews(collectionView, spinner)
        self.collectionView = collectionView
        setConstraints()
        
        spinner.startAnimating()
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public func configure(with vm: RMEpisodeDetailViewViewModel) {
        episodeDeatilVM = vm 
    }
    
    // MARK: - Private
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { section, _ in
            self.layout(for: section)
        }
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        collectionView.alpha = 0
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RMEpisodeInfoCollectionViewCell.self)
        collectionView.register(RMCharacterCollectionViewCell.self)
        
        return collectionView
    }
    
    private func setConstraints() {
        guard let collectionView else { return }
        NSLayoutConstraint.activate([
            spinner.heightAnchor.constraint(equalToConstant: Constants.Spinner.height),
            spinner.widthAnchor.constraint(equalToConstant: Constants.Spinner.width),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
        
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension RMEpisodeDetailView: UICollectionViewDataSource {
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        episodeDeatilVM?.cellViewModels.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let sections = episodeDeatilVM?.cellViewModels else { return 0 }
        switch sections[section] {
        case .information(let vms):
            return vms.count
        case .characters(let vms):
            return vms.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let sections = episodeDeatilVM?.cellViewModels else { fatalError("No viewModel") }
        
        switch sections[indexPath.section] {
        case .information(let vms):
            let cell = dequeueCell(
                in: collectionView,
                of: RMEpisodeInfoCollectionViewCell.self,
                for: indexPath
            )
            cell.configure(with: vms[indexPath.row])
            return cell
        case .characters(let vms):

            let cell = dequeueCell(
                in: collectionView,
                of: RMCharacterCollectionViewCell.self,
                for: indexPath
            )
            cell.configure(with: vms[indexPath.row])
            return cell
        }
    }
    
    private func dequeueCell<T>(
        in collectionView: UICollectionView,
        of type: T.Type,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = collectionView.dequeueReusableCell(T.self, indexPath: indexPath) else {
            fatalError("Unsupported cell")
        }
        return cell
    }
}

extension RMEpisodeDetailView: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

private extension RMEpisodeDetailView {
    
    func layout(for section: Int) -> NSCollectionLayoutSection {
        guard let sections = episodeDeatilVM?.cellViewModels else {
            return createInfoLayout()
        }
        switch sections[section] {
        case .information:
            return createInfoLayout()
        case .characters:
            return createCharacterLayout()
        }
    }
    
    func createCharacterLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
           layoutSize: .init(
               widthDimension: .fractionalWidth(
                   Constants.Item.width
               ),
               heightDimension: .fractionalHeight(
                   Constants.Item.height
               )
           )
        )
       
       item.contentInsets = NSDirectionalEdgeInsets(
           top: Constants.Item.Inset.top,
           leading: Constants.Item.Inset.leading,
           bottom: Constants.Item.Inset.bottom,
           trailing: Constants.Item.Inset.trailing
       )
       
       let group = NSCollectionLayoutGroup.horizontal(
           layoutSize: .init(
               widthDimension: .fractionalWidth(
                0.5
               ),
               heightDimension: .absolute(
                   240
               )
           ),
           subitems: [item, item]
       )
       
       return NSCollectionLayoutSection(group: group)
    }
    
    
    func createInfoLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
           layoutSize: .init(
               widthDimension: .fractionalWidth(
                   Constants.Item.width
               ),
               heightDimension: .fractionalHeight(
                   Constants.Item.height
               )
           )
        )
       
       item.contentInsets = NSDirectionalEdgeInsets(
           top: Constants.Item.Inset.top,
           leading: Constants.Item.Inset.leading,
           bottom: Constants.Item.Inset.bottom,
           trailing: Constants.Item.Inset.trailing
       )
       
       let group = NSCollectionLayoutGroup.vertical(
           layoutSize: .init(
               widthDimension: .fractionalWidth(
                   Constants.Group.width
               ),
               heightDimension: .absolute(
                   Constants.Group.height
               )
           ),
           subitems: [item]
       )
       
       return NSCollectionLayoutSection(group: group)
    }
    
    struct Constants {
        
        static let duration: TimeInterval = 0.3
        
        struct Spinner {
            static let height: CGFloat = 100
            static let width: CGFloat = 100
        }
        
        struct Item {
            static let width: CGFloat = 1
            static let height: CGFloat = 1
            
            struct Inset {
                static let top: CGFloat = 10
                static let leading: CGFloat = 10
                static let trailing: CGFloat = 10
                static let bottom: CGFloat = 10
            }
        }
        
        struct Group {
            static let width: CGFloat = 1
            static let height: CGFloat = 100
        }
    }
}
