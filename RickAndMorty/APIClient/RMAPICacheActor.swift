//
//  RMAPICacheActor.swift
//  RickAndMorty
//
//  Created by Саша Восколович on 30.06.2024.
//

import Foundation


//  Manages in memory session scoped API caches
actor RMAPICacheActor {
    
    typealias CacheData = [RMEndpoint: NSCache<NSString, NSData>]
    
    private var cacheDictionary: CacheData = RMEndpoint.allCases
        .reduce(into: [:]) { $0[$1] = NSCache<NSString, NSData>() }
   
    
    init() {}
    
    public func cachedResponse(for endpoint: RMEndpoint, url: URL?) -> Data? {
        guard let targetCache = cacheDictionary[endpoint],
              let url else { return nil }
        let key = url.absoluteString as NSString
        return targetCache.object(forKey: key) as? Data
    }
    
    
    public func setCache(for endpoint: RMEndpoint, url: URL?, data: Data) {
        guard let targetCache = cacheDictionary[endpoint],
                let url else { return  }
        let key = url.absoluteString as NSString
        targetCache.setObject(data as NSData, forKey: key)
    }
}
