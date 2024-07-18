//
//  ServiceAsync.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 30.06.2024.
//

import Foundation


 protocol AsyncService {
    associatedtype Response: JsonModel
    func execute(_ request: some Request) async throws -> Response
}

extension AsyncService {
    func request(from rmRequest: some Request) -> URLRequest? {
        guard let url = rmRequest.url,
              let rm = rmRequest as? RMRequest else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = rm.httpMethod
        return request
    }
}
