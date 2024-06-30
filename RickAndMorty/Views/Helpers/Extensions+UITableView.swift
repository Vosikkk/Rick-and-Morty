//
//  Extensions+UITableView.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 30.06.2024.
//

import UIKit


extension UITableView {
    
    func register(_ type: UITableViewCell.Type) {
        let className = String(describing: type)
        register(type, forCellReuseIdentifier: className)
    }
    
    func dequeueReusableCell<T>(_ type: T.Type, for indexPath: IndexPath) -> T? {
        let className = String(describing: type)
        return dequeueReusableCell(withIdentifier: className, for: indexPath) as? T
    }
}
