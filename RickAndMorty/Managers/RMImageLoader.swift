//
//  RMImageLoader.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 24.06.2024.
//
import Foundation
import UIKit

 final class RMImageLoader {
    
    typealias Completion = (Result<Data, Error>) -> Void
    
    private var imageDataCache = NSCache<NSString, NSData>()
    
     init() {}
    
    
    /// Get image data with URL
    /// - Parameters:
    ///   - url: Source url
    ///   - completion: Callback
     func downloadImage(_ url: URL, completion: @escaping Completion) {
        let key = url.absoluteString as NSString
        if let data = imageDataCache.object(forKey: key) {
            completion(.success(data as Data))
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data, error == nil else {
                completion(.failure(error ?? URLError.init(.badServerResponse)))
                return
            }
            let value = data as NSData
            self?.imageDataCache.setObject(value, forKey: key)
            completion(.success(data))
        }
        task.resume()
    }
}
