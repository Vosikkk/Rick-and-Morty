//
//  RMSettingsOption.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 28.06.2024.
//

import Foundation

enum RMSettingsOption: CaseIterable {
    
    case rateApp
    case contactUs
    case terms
    case privacy
    case apiReference
    case viewSeries
    case viewCode
    
    
    
    var displayTitle: String {
        switch self {
        case .rateApp:
            return "Rate App"
        case .contactUs:
            return "Contact Us"
        case .terms:
            return "Terms of Service"
        case .privacy:
            return "Privacy Policy"
        case .apiReference:
            return "API Reference"
        case .viewSeries:
            return "View Video Series"
        case .viewCode:
            return "View App Code"
        }
    }
    
    var targetUrl: URL? {
        switch self {
        case .rateApp:
            return nil
        case .contactUs:
            return URL(string: "https://about.google/contact-google/")
        case .terms:
            return URL(string: "https://policies.google.com/terms")
        case .privacy:
            return URL(string: "https://policies.google.com/")
        case .apiReference:
            <#code#>
        case .viewSeries:
            <#code#>
        case .viewCode:
            <#code#>
        }
    }
}
