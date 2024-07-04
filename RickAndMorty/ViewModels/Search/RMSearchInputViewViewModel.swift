//
//  RMSearchInputViewViewModel.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 03.07.2024.
//

import Foundation

final class RMSearchInputViewViewModel {
    
    typealias `Type` = RMSearchViewController.Config.`Type`
    
    private let type: `Type`
    
    public var hasDynamicOptions: Bool {
        switch type {
        case .character, .location:
            return true
        case .episode:
            return false
        }
    }
    
    public var options: [DynamicOption] {
        switch type {
        case .character:
            return [.status, .gender]
        case .episode:
            return []
        case .location:
            return [.locationType]
        }
    }
    
    public var searchPlaceholderText: String {
        switch type {
        case .character:
            return "Character Name"
        case .episode:
            return "Episode Title"
        case .location:
            return "Location Name"
        }
    }
    
    init(with type: `Type`) {
        self.type = type
    }
    
    
    // MARK: - Netsed Type
    
    enum DynamicOption: String {
        case status = "Status"
        case gender = "Gender"
        case locationType = "Location Type"
        
        var choices: [String] {
            switch self {
            case .status:
                return OptionCategory.Status.allValues
            case .gender:
                return OptionCategory.Gender.allValues
            case .locationType:
                return OptionCategory.Location.allValues
            }
        }
    }
}

private extension RMSearchInputViewViewModel {
    
    enum OptionCategory {
        enum Status: String, CaseIterable, OptionType {
            case alive, dead, unknown
            
            static var allValues: [String] {
                Self.allCases.map { $0.rawValue }
            }
        }
        enum Gender: String, CaseIterable, OptionType {
            case male, female, genderless, unknown
            
            static var allValues: [String] {
                Self.allCases.map { $0.rawValue }
            }
        }
        enum Location: String, CaseIterable, OptionType {
            case cluster, planet, microverse
            
            static var allValues: [String] {
                Self.allCases.map { $0.rawValue }
            }
        }
    }
}

protocol OptionType {
    static var allValues: [String] { get }
}
