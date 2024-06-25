//
//  Extensions+UICollectionView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 25.06.2024.
//

import UIKit

public extension UICollectionView {
    
    func register(_ type: UICollectionViewCell.Type) {
        let className = String(describing: type)
        register(type, forCellWithReuseIdentifier: className)
    }
    
    func dequeueReusableCell<T>(_ type: T.Type, indexPath: IndexPath) -> T? {
        let className = String(describing: type)
        return dequeueReusableCell(withReuseIdentifier: className, for: indexPath) as? T
    }
}
