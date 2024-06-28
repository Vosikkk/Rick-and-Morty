//
//  RMSettingsCellViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 28.06.2024.
//

import UIKit

struct RMSettingsCellViewModel: Identifiable, Hashable {
    
    let id: UUID = .init()
   
    private let type: RMSettingsOption
    
    public var image: UIImage? {
        type.iconImage
    }
    public var title: String {
        type.displayTitle
    }

    public var iconContainerColor: UIColor {
        type.iconContainerColor
    }
    
    init(type: RMSettingsOption) {
        self.type = type
    }
}
