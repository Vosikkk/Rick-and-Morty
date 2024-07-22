//
//  DataProcessor.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 20.07.2024.
//

import Foundation


final class DataProcessor<T: JsonModel, U: Hashable> {
    
    private(set) var items: [T] = []
    private(set) var cellViewModels: [U] = []
    
    private(set) var apiInfo: Info?
    
    func handleInitial<E: ResponseModel>(
        response: E,
        createViewModels: (ArraySlice<T>) -> [U]
    ) {
        apiInfo = response.info
        items = response.results as! [T]
        cellViewModels = createViewModels(items[...])
    }
    
    func handleAdditional<E: ResponseModel>(
        response: E,
        fromIndex index: Int,
        createViewModels: (ArraySlice<T>) -> [U]
    ) {
        apiInfo = response.info
        items.append(contentsOf: response.results as! [T])
        cellViewModels.append(contentsOf: createViewModels(items[index...]))
    }
    
    func item(at index: Int) -> T? {
        guard index < items.count, index >= 0 else {
            return nil
        }
        return items[index]
    }
}


protocol DataProcess {
   
    associatedtype Model: JsonModel
    associatedtype ViewModel: Hashable
    associatedtype Response: ResponseModel
   
    var items: [Model] { get }
    var cellViewModels: [ViewModel] { get }
    
    var apiInfo: Info? { get }
    
    func handleInitial(response: Response)
    
    func handleAdditional(response: Response)
    
    func item(at index: Int) -> Model?
}


final class DataProcessorrr<Mapper: Map, Resp: ResponseModel>: DataProcess 
where Mapper.JsModel == Resp.ResultResponse {
    
    typealias Model = Mapper.JsModel
    typealias ViewModel = Mapper.ViewModel
    typealias Response = Resp
    
    private(set) var items: [Model] = []
    private(set) var cellViewModels: [ViewModel] = []
    
    private(set) var apiInfo: Info?
    
    private let mapper: Mapper
    
    init(items: [Model] = [], mapper: Mapper) {
        self.items = items
        self.mapper = mapper
    }
    
    
    func handleInitial(response: Response) {
        updateData(with: response)
    }
    
    func handleAdditional(response: Response) {
        appendData(with: response)
    }
    
    private func updateData(with response: Response) {
        apiInfo = response.info
        items = response.results
        cellViewModels = mapper.map(from: items)
    }
    
    private func appendData(with response: Response) {
        apiInfo = response.info
        items.append(contentsOf: response.results)
        cellViewModels.append(contentsOf: mapper.map(from: response.results))
    }
    
    func item(at index: Int) -> Model? {
        guard index < items.count, index >= 0 else {
            return nil
        }
        return items[index]
    }
}
