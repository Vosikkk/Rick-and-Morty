//
//  Service.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 22.06.2024.
//

import Foundation

///  Each who wants work with client have to implment the protocol
 protocol Service {
    
     var imageLoader: RMImageLoader { get }
     
    func execute<T: JsonModel>(
        _ request: some Request,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void)
}

extension Service {
   
    func request(from rmRequest: some Request) -> URLRequest? {
        guard let url = rmRequest.url,
              let rm = rmRequest as? RMRequest else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = rm.httpMethod
        return request
    }
}

