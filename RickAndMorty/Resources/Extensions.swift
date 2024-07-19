//
//  Extensions.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

extension UIDevice {
    static let isiPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
}


