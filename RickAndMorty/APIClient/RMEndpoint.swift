//
//  RMEndpoint.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 21.06.2024.
//

import Foundation

/// Represents unique API endpoint
@frozen public enum RMEndpoint: String {
    /// Endpoints to get info of each kind of data
    case character, location, episode
}
