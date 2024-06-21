//
//  RMService.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation


///  Each who wants work with client have to implment the protocol
protocol Service {
    func execute(_ request: some Request, completion: @escaping () -> Void)
    func execute(_ request: some Request) async throws
}


/// Primary API service object to get Rick and Morty data
final class RMService: Service {
    
    /// Send Rick and Morty API call
    /// - Parameters:
    ///   - request: Instance of Request opaque types
    ///   - completion: Call back with data or error
    func execute(_ request: some Request, completion: @escaping () -> Void) {
            
    }
    
    
    ///  /// Send Rick and Morty API call async
    /// - Parameter request: Instance of Request opaque types
    func execute(_ request: some Request) async throws {
            
    }
    
    
    
    
}

