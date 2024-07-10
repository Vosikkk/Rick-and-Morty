//
//  RMSearchResultType.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 04.07.2024.
//

import Foundation

enum RMSearchResultType {
    case characters([RMCharacterCollectionViewCellViewModel])
    case locations([RMLocationTableViewCellViewModel])
    case episodes([RMCharacterEpisodeCollectionViewCellViewModel])
}
