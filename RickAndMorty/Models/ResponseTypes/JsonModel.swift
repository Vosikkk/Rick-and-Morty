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

protocol ResponseModel: JsonModel {
    associatedtype ResultResponse: JsonModel
   
    var results: [ResultResponse] { get }
    var info: Info { get }
    
}
