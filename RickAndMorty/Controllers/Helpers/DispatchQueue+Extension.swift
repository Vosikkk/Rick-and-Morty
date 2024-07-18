//
//  DispatchQueue+Extension.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 17.07.2024.
//

import Foundation

extension DispatchQueue {
    
    static func mainAsyncIfNeeded(execute work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            main.async(execute: work)
        }
    }
}
