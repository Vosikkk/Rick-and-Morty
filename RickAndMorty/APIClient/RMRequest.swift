//
//  RMRequest.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation

public protocol Request {
    var url: URL? { get }
}


/// Object that represents a single API call
public final class RMRequest: Request {
   
    
    /// Desired endpoint
    private let endpoint: RMEndpoint
    
    /// Path components for API, if any
    private let pathComponents: Set<String>
    
    /// Query  arguments for API, if any
    private let queryParameters: [URLQueryItem]
    
    
    /// Constracted url for the api request in string format
    private var urlString: String {
        var string = Constants.baseUrl
        string += "/"
        string += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach {
                string += "/\($0)"
            }
        }
        
        if !queryParameters.isEmpty {
            string += "?"
            let argumentStrimg = queryParameters
                .compactMap {
                    guard let value = $0.value else { return nil }
                    return "\($0.name)=\(value)"
                }
                .joined(separator: "&")
            string += argumentStrimg
        }
        return string
    }
    
    
    
    /// Computed & constructed API url
    public var url: URL? {
        URL(string: urlString)
    }
    
    /// Desired http method
    public let httpMethod: String = "GET"
    
    
    /// Construct request
    /// - Parameters:
    ///   - endpoint: Target endpoint
    ///   - pathComponents: Collection of path components
    ///   - queryParameters: Collection of query parameters
    public init(
        endpoint: RMEndpoint,
        pathComponents: Set<String> = [],
        queryParameters: [URLQueryItem] = []
    ) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
    
    
    /// API constants
    private struct Constants {
        static let baseUrl = "https://rickandmortyapi.com/api"
    }
}