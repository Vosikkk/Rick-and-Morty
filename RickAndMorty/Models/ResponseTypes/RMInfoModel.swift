//
//  RMInfoModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 18.07.2024.
//

import Foundation

public struct Info: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
