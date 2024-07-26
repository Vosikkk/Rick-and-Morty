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
    let endpoint: RMEndpoint
    
    /// Path components for API, if any
    private let pathComponents: [String]
    
    /// Query  arguments for API, if any
    private let queryParameters: [URLQueryItem]
    
    
    /// Constracted url for the api request in string format
    private var urlString: String {
        
        var string = Constants.baseUrl
        string += "/"
        string += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach { string += "/\($0)" }
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
        pathComponents: [String] = [],
        queryParameters: [URLQueryItem] = []
    ) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
    
    
    
    /// Attempt to create request
    /// - Parameter url: URL to parse
    convenience init?(url: URL) {
        let string = url.absoluteString
        if !string.contains(Constants.baseUrl) {
            return nil
        }
        let trimmed = string.replacingOccurrences(of: Constants.baseUrl+"/", with: "")
        if trimmed.contains("/") {
            let components = trimmed.components(separatedBy: "/")
            if !components.isEmpty {
                let endpointString = components[0]
                var pathComponents: [String] = []
                if components.count > 1 {
                    pathComponents = components
                    pathComponents.removeFirst()
                }
                if let rmEndpoint = RMEndpoint(rawValue: endpointString) {
                    self.init(endpoint: rmEndpoint, pathComponents: pathComponents)
                    return
                }
            }
        } else if trimmed.contains("?") {
            let components = trimmed.components(separatedBy: "?")
            if !components.isEmpty, components.count >= 2 {
                let endpointString = components[0]
                let queryItemsString = components[1]
                let queryItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap {
                        guard $0.contains("=") else { return nil }
                        let parts = $0.components(separatedBy: "=")
                        return URLQueryItem(name: parts[0], value: parts[1])
                    }
                if let rmEndpoint = RMEndpoint(rawValue: endpointString) {
                    self.init(endpoint: rmEndpoint, queryParameters: queryItems)
                    return
                }
            }
        }
        return nil
    }
    
    
    /// API constants
    private struct Constants {
        static let baseUrl = "https://rickandmortyapi.com/api"
    }
}

