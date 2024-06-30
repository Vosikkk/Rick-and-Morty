//
//  RMLocationTableViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 30.06.2024.
//

import Foundation

struct RMLocationTableViewCellViewModel {
    
    private let location: RMLocation
    
    public var name: String {
        location.name
    }
    
    public var type: String {
        "Type: "+location.type
    }
    
    public var dimension: String {
        location.dimension
    }
    
    
    init(location: RMLocation) {
        self.location = location
    }
}

extension RMLocationTableViewCellViewModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(location.id)
    }
    
    static func == (
        lhs: RMLocationTableViewCellViewModel,
        rhs: RMLocationTableViewCellViewModel
    ) -> Bool {
        lhs.location.id == rhs.location.id
    }
}
