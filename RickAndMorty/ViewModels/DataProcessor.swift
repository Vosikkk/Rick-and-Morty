//
//  DataProcessor.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 20.07.2024.
//

import Foundation


final class DataProcessor<T: JsonModel, U: Hashable> {
    
    private var items: [T] = []
    private var calculator: CalculatorIndexPaths = .init()
    private(set) var cellViewModels: [U] = []
    
    var apiInfo: Info?
    
    var isLoadingMore: Bool = false {
        didSet {
            if isLoadingMore, calculator._lastIndex != items.endIndex {
                calculator._lastIndex = items.endIndex
            }
        }
    }
    
    func handleInitial<E: ResponseModel>(response: E, createViewModels: (ArraySlice<T>) -> [U]) {
        apiInfo = response.info
        items = response.results as! [T]
        cellViewModels = createViewModels(items[...])
    }
    
    func handleAdditionall<E: ResponseModel>(response: E, createViewModels: (ArraySlice<T>) -> [U]) {
        apiInfo = response.info
        items.append(contentsOf: response.results as! [T])
        cellViewModels.append(contentsOf: createViewModels(items[calculator._lastIndex...]))
    }
       
    
    func item(at index: Int) -> T? {
        guard index < items.count, index >= 0 else {
            return nil
        }
        return items[index]
    }
}
