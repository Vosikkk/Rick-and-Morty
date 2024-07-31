//
//  RMLocationDetailView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 01.07.2024.
//

import UIKit

protocol RMLocationDetailViewDelegate: AnyObject {
    func rmLocationDetailView(
        _ detailView: RMLocationDetailView,
        didSelect character: RMCharacter
    )
}

final class RMLocationDetailView: UIView {
    
    public weak var delegate: RMLocationDetailViewDelegate?
    
    private var locationDeatilVM: RMLocationDetailViewViewModel? {
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
    
    public func configure(with vm: RMLocationDetailViewViewModel) {
        locationDeatilVM = vm
    }
    
    // MARK: - UI configure
    
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


    // MARK: - UICollectionViewDataSource

    extension RMLocationDetailView: UICollectionViewDataSource {
       
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            locationDeatilVM?.cellViewModels.count ?? 0
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            numberOfItemsInSection section: Int
        ) -> Int {
            guard let sections = locationDeatilVM?.cellViewModels else {
                return 0
            }
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
            
            guard let sections = locationDeatilVM?.cellViewModels else {
                fatalError("No viewModel")
            }
            
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
            guard let cell = collectionView.dequeueReusableCell(
                T.self,
                indexPath: indexPath
            ) else {
                fatalError("Unsupported cell")
            }
            return cell
        }
    }

    // MARK: - UICollectionViewDelegate

    extension RMLocationDetailView: UICollectionViewDelegate {
        
        func collectionView(
            _ collectionView: UICollectionView,
            didSelectItemAt indexPath: IndexPath
        ) {
            collectionView.deselectItem(at: indexPath, animated: true)
            guard let vm = locationDeatilVM else { return }
             
            let sections = vm.cellViewModels
            
            switch sections[indexPath.section] {
            case .information:
              break
            case .characters:
                if let character = vm.character(at: indexPath.row) {
                    delegate?.rmLocationDetailView(self, didSelect: character)
                }
            }
        }
    }


    // MARK: - UICollection Layout

    private extension RMLocationDetailView {
        
        func layout(for section: Int) -> NSCollectionLayoutSection {
            guard let sections = locationDeatilVM?.cellViewModels else {
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
                    UIDevice.isiPhone ? Constants.CharacterItem.width :
                        Constants.CharacterItem.width / 2
                   ),
                   heightDimension: .fractionalHeight(
                       Constants.CharacterItem.height
                   )
               )
            )
           
           item.contentInsets = NSDirectionalEdgeInsets(
               top: Constants.CharacterItem.Inset.top,
               leading: Constants.CharacterItem.Inset.leading,
               bottom: Constants.CharacterItem.Inset.bottom,
               trailing: Constants.CharacterItem.Inset.trailing
           )
           
           let group = NSCollectionLayoutGroup.horizontal(
               layoutSize: .init(
                   widthDimension: .fractionalWidth(
                    Constants.CharacterGroup.width
                   ),
                   heightDimension: .absolute(
                    UIDevice.isiPhone ? Constants.CharacterGroup.height :
                        Constants.CharacterGroup.height + 60
                   )
               ),
               subitems: UIDevice.isiPhone ? [item, item] :
                [item, item, item, item]
           )
           
           return NSCollectionLayoutSection(group: group)
        }
        
        
        func createInfoLayout() -> NSCollectionLayoutSection {
            let item = NSCollectionLayoutItem(
               layoutSize: .init(
                   widthDimension: .fractionalWidth(
                       Constants.InfoItem.width
                   ),
                   heightDimension: .fractionalHeight(
                       Constants.InfoItem.height
                   )
               )
            )
           
           item.contentInsets = NSDirectionalEdgeInsets(
               top: Constants.InfoItem.Inset.top,
               leading: Constants.InfoItem.Inset.leading,
               bottom: Constants.InfoItem.Inset.bottom,
               trailing: Constants.InfoItem.Inset.trailing
           )
           
           let group = NSCollectionLayoutGroup.vertical(
               layoutSize: .init(
                   widthDimension: .fractionalWidth(
                       Constants.InfoGroup.width
                   ),
                   heightDimension: .absolute(
                       Constants.InfoGroup.height
                   )
               ),
               subitems: [item]
           )
           
           return NSCollectionLayoutSection(group: group)
        }
    }

    // MARK: - Constants

private extension RMLocationDetailView {
       
        struct Constants {
            
            static let duration: TimeInterval = 0.3
            
            struct Spinner {
                static let height: CGFloat = 100
                static let width: CGFloat = 100
            }
            
            struct InfoItem {
                static let width: CGFloat = 1.0
                static let height: CGFloat = 1.0
                
                struct Inset {
                    static let top: CGFloat = 10
                    static let leading: CGFloat = 10
                    static let trailing: CGFloat = 10
                    static let bottom: CGFloat = 10
                }
            }
            
            struct CharacterItem {
                static let width: CGFloat = 0.5
                static let height: CGFloat = 1.0
                
                struct Inset {
                    static let top: CGFloat = 5
                    static let leading: CGFloat = 10
                    static let trailing: CGFloat = 10
                    static let bottom: CGFloat = 5
                }
            }
            
            struct InfoGroup {
                static let width: CGFloat = 1.0
                static let height: CGFloat = 80
            }
            
            struct CharacterGroup {
                static let width: CGFloat = 1.0
                static let height: CGFloat = 240
            }
        }
    }
