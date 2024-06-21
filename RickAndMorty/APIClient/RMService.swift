//
//  RMService.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation


///  Each who wants work with client have to implment the protocol
protocol Service {
    func execute<T: Codable>(
        _ request: some Request,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void)
   
    func execute<T: Codable>(
        _ request: some Request,
        expecting type: some Codable
    ) async throws -> T
}


/// Primary API service object to get Rick and Morty data
final class RMService: Service {
  
    
    /// Send Rick and Morty API call
    /// - Parameters:
    ///   - request: Instance of Request opaque types
    ///   - type: The type of object we expect to getback
    ///   - completion: Call back with data or error
    func execute<T: Codable>(
        _ request: some Request,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void) {
            
    }
    
    
    ///  /// Send Rick and Morty API call async
    /// - Parameter request: Instance of Request opaque types
    func execute<T: Codable>(
        _ request: some Request,
        expecting type: some Codable)
    async throws -> T {
        RMLocation(id: <#T##Int#>, name: <#T##String#>, type: <#T##String#>, dimension: <#T##String#>, residents: <#T##[String]#>, url: <#T##String#>, created: <#T##String#>) as! T
        
    }
}

