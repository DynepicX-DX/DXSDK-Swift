//
//  PlayPortalCollection.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 11/8/18.
//

import Foundation

//fileprivate enum CollectionRouter: URLRequestConvertible {
//
//    case create(body: [String: Any])
//    case read
//    case add(url: String, body: )
//    case remove
//    case update
//    case delete
//
//    func asURLRequest() -> URLRequest? {
//        switch self {
//
//        }
//    }
//}

public final class PlayPortalCollection {
    
    //  MARK: - Properties
    
    //  Singleton instance
    public static let shared = PlayPortalCollection()
    
    //  Handler for making api requests
    private var requestHandler = globalRequestHandler
    
    
    //  MARK: - Initializers
    
    //  Private init to force use of singleton
    private init() {}
    
    public func create(
        collectionNamed collectionName: String)
        -> Void
    {
        
    }
    
    public func add(
        toCollection collectionName: String)
        -> Void
    {
        
    }
    
    public func remove(
        fromCollection collectionName: String)
    {
        
    }
    
    public func update(
        inCollection collectionName: String)
        -> Void
    {
        
    }
    
    public func delete(
        collectionNamed collectionName: String)
        -> Void
    {
        
    }
}
