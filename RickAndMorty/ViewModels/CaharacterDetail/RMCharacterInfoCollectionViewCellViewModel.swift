//
//  RMCharacterInfoCollectionViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 25.06.2024.
//

import UIKit

final class RMCharacterInfoCollectionViewCellViewModel {
    
    private let dateFormatter: FormatterOfDate = .init()
    
    public var displayValue: String {
        if value.isEmpty {
            return "None"
        }
        if type == .created {
            return dateFormatter.createShortDate(from: value)
        }
        
        return value
    }
    
    public var title: String {
        type.title
    }
    
    public var iconImage: UIImage? {
        type.iconImage
    }
    
    public var tintColor: UIColor {
        type.tintColor
    }

    
    private let value: String
    private let type: `Type`
    
    
    init(type: `Type`, value: String) {
        self.value = value
        self.type = type
    }
}



extension RMCharacterInfoCollectionViewCellViewModel {
    
    enum `Type`: String {
        case status
        case gender
        case type
        case species
        case origin
        case created
        case location
        case episodeCount
        
        
        var title: String {
            rawValue != Self.episodeCount.rawValue ?
            rawValue.uppercased() : "EPISODE COUNT"
        }
        
        
        var iconImage: UIImage? {
            switch self {
            case .status:
                return UIImage(systemName: "bell")
            case .gender:
                return UIImage(systemName: "bell")
            case .type:
                return UIImage(systemName: "bell")
            case .species:
                return UIImage(systemName: "bell")
            case .origin:
                return UIImage(systemName: "bell")
            case .created:
                return UIImage(systemName: "bell")
            case .location:
                return UIImage(systemName: "bell")
            case .episodeCount:
                return UIImage(systemName: "bell")
            }
        }
        
        
        var tintColor: UIColor {
            switch self {
            case .status:
                return .systemBlue
            case .gender:
                return .systemRed
            case .type:
                return .systemPurple
            case .species:
                return .systemGreen
            case .origin:
                return .systemOrange
            case .created:
                return .systemPink
            case .location:
                return .systemYellow
            case .episodeCount:
                return .systemMint
            }
        }
    }
}
