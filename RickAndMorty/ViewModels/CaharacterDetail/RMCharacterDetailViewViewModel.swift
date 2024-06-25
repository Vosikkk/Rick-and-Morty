//
//  RMCharacterDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 23.06.2024.
//

import Foundation
import UIKit

final class RMCharacterDetailViewViewModel {
    
    private let character: RMCharacter
    
    
    enum SectionType {
        case photo(vm: RMCharacterPhotoCollectionViewCellViewModel)
        case information(vms: [RMCharacterInfoCollectionViewCellViewModel])
        case episodes(vms: [RMCharacterEpisodeCollectionViewCellViewModel])
    }
    
    public var sections: [SectionType] = []
    
    
    // MARK: - Init
    init(character: RMCharacter) {
        self.character = character
        setupSections()
    }
    
    private var requestUrl: URL? {
        URL(string: character.url)
    }
    
    public var title: String {
        character.name.uppercased()
    }
    
    
    private func setupSections() {
        sections = [
            .photo(vm: .init()),
            .information(vms: [
                .init(),
                .init(),
                .init(),
                .init(),
            ]),
            .episodes(vms: [
                .init(),
                .init(),
                .init(),
                .init(),
            ])
            
        ]
    }
    
    
    public func createPhotoSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(
                    Constants.PhotoSection.ItemLayout.widthDimension
                ),
                heightDimension: .fractionalHeight(
                    Constants.PhotoSection.ItemLayout.heightDimension
                )
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.PhotoSection.ItemLayout.ContentInset.top,
            leading: Constants.PhotoSection.ItemLayout.ContentInset.leading,
            bottom: Constants.PhotoSection.ItemLayout.ContentInset.bottom,
            trailing: Constants.PhotoSection.ItemLayout.ContentInset.trailing
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(
                    Constants.PhotoSection.GroupLayout.widthDimension
                ),
                heightDimension: .fractionalHeight(
                    Constants.PhotoSection.GroupLayout.heightDimension
                )
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    public func createInfoSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(
                    Constants.InfoSection.ItemLayout.widthDimension
                ),
                heightDimension: .fractionalHeight(
                    Constants.InfoSection.ItemLayout.heightDimension
                )
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.InfoSection.ItemLayout.ContentInset.top,
            leading: Constants.InfoSection.ItemLayout.ContentInset.leading,
            bottom: Constants.InfoSection.ItemLayout.ContentInset.bottom,
            trailing: Constants.InfoSection.ItemLayout.ContentInset.trailing
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(
                    Constants.InfoSection.GroupLayout.widthDimension
                ),
                heightDimension: .absolute(
                    Constants.InfoSection.GroupLayout.heightDimension
                )
            ),
            subitems: [item, item]
        )
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    
    public func createEpisodeSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(
                    Constants.EpisodeSection.ItemLayout.widthDimension
                ),
                heightDimension: .fractionalHeight(
                    Constants.EpisodeSection.ItemLayout.heightDimension
                )
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.EpisodeSection.ItemLayout.ContentInset.top,
            leading: Constants.EpisodeSection.ItemLayout.ContentInset.leading,
            bottom: Constants.EpisodeSection.ItemLayout.ContentInset.bottom,
            trailing: Constants.EpisodeSection.ItemLayout.ContentInset.trailing
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(
                    Constants.EpisodeSection.GroupLayout.widthDimension
                ),
                heightDimension: .absolute(
                    Constants.EpisodeSection.GroupLayout.heightDimension
                )
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
}


private extension RMCharacterDetailViewViewModel {
    
    struct Constants {
        
        struct PhotoSection {
            
            struct ItemLayout {
                
                static let widthDimension: CGFloat = 1.0
                static let heightDimension: CGFloat = 1.0
                
                struct ContentInset {
                    static let top: CGFloat = 0
                    static let leading: CGFloat = 0
                    static let bottom: CGFloat = 10
                    static let trailing: CGFloat = 0
                }
            }
            
            struct GroupLayout {
                static let widthDimension: CGFloat = 1.0
                static let heightDimension: CGFloat = 0.5
            }
        }
        
        struct InfoSection {
            struct ItemLayout {
                
                static let widthDimension: CGFloat = 0.5
                static let heightDimension: CGFloat = 1.0
                
                struct ContentInset {
                    static let top: CGFloat = 2
                    static let leading: CGFloat = 2
                    static let bottom: CGFloat = 2
                    static let trailing: CGFloat = 2
                }
            }
            
            struct GroupLayout {
                static let widthDimension: CGFloat = 1.0
                static let heightDimension: CGFloat = 150
            }
        }
        
        struct EpisodeSection {
            struct ItemLayout {
                
                static let widthDimension: CGFloat = 1.0
                static let heightDimension: CGFloat = 1.0
                
                struct ContentInset {
                    static let top: CGFloat = 10
                    static let leading: CGFloat = 5
                    static let bottom: CGFloat = 10
                    static let trailing: CGFloat = 8
                }
            }
            
            struct GroupLayout {
                static let widthDimension: CGFloat = 0.8
                static let heightDimension: CGFloat = 150
            }
        }
    }
}
