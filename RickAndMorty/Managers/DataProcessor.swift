//
//  DataProcessor.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 20.07.2024.
//

import Foundation


protocol DataProcess {
   
    associatedtype Model: JsonModel
    associatedtype ViewModel: Hashable
    associatedtype Response: ResponseModel
   
    var items: [Model] { get }
    var cellViewModels: [ViewModel] { get }
    
    var apiInfo: Info? { get }
    
    func handleInitial(_ response: Response)
    
    func handleAdditional(_ response: Response)
    
    func item(at index: Int) -> Model?
}


final class DataProcessor<Mapper: Map, Resp: ResponseModel>: DataProcess 
where Mapper.JsModel == Resp.ResultResponse {
    
    typealias Model = Mapper.JsModel
    typealias ViewModel = Mapper.ViewModel
    typealias Response = Resp
    
    private(set) var items: [Model] = []
    private(set) var cellViewModels: [ViewModel] = []
    
    private(set) var apiInfo: Info?
    
    private let mapper: Mapper
    
    init(mapper: Mapper) {
        self.mapper = mapper
    }
    
    convenience init(response: Resp, mapper: Mapper) {
        self.init(mapper: mapper)
        handleInitial(response)
    }
    
    
    func handleInitial(_ response: Response) {
        updateData(with: response, append: false)
    }
    
    func handleAdditional(_ response: Response) {
        updateData(with: response, append: true)
    }
    
    private func updateData(with response: Response, append: Bool) {
        apiInfo = response.info
        if append {
            items.append(contentsOf: response.results)
            cellViewModels.append(contentsOf: mapper.map(from: response.results))
        } else {
            items = response.results
            cellViewModels = mapper.map(from: response.results)
        }
    }
    
    func item(at index: Int) -> Model? {
        guard index < items.count, index >= 0 else {
            return nil
        }
        return items[index]
    }
}
