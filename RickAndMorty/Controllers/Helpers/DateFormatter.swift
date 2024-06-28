//
//  DateFormatter.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 28.06.2024.
//

import Foundation

struct FormatterOfDate {
    
    // Default date format
    private let defaultDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Initializer to set the date format
    init(dateFormat: String? = nil, timeZone: TimeZone = .current) {
        dateFormatter.dateFormat = dateFormat ?? defaultDateFormat
        dateFormatter.timeZone = timeZone
    }
    
    
    public func createShortDate(from value: String) -> String {
        if let date = parseDate(from: value) {
            return shortDateFormatter.string(from: date)
        }
        return ""
    }
    
    private func parseDate(from value: String) -> Date? {
        dateFormatter.date(from: value)
    }
}
