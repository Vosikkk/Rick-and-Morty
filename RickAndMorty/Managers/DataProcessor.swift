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
