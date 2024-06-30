//
//  JsonModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 30.06.2024.
//

import Foundation

public protocol JsonModel: Decodable {
    init(json: Data) throws
}
