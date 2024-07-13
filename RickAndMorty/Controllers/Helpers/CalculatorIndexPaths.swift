//
//  CalculatorIndexPaths.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 13.07.2024.
//

import Foundation

struct CalculatorIndexPaths {
    
    private var lastIndex: Int
    
    
    init(lastIndex: Int = 0) {
        self.lastIndex = lastIndex
    }
    
    public var _lastIndex: Int {
        get {
            lastIndex
        }
        set {
            if newValue != lastIndex {
                lastIndex = newValue
            }
        }
    }
    
    func calculateIndexPaths(count: Int) -> [IndexPath] {
        return (lastIndex..<lastIndex + count)
            .map {
                IndexPath(item: $0, section: 0)
            }
    }
}
