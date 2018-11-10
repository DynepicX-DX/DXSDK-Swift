//
//  PlayPortalCollection.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 11/8/18.
//

import Foundation

public final class PlayPortalCollection {
    
    public static let shared = PlayPortalCollection()
    private var requestHandler: RequestHandler = globalRequestHandler
    private var responseHandler: ResponseHandler = globalResponseHandler
    private var collections = [String: [Codable]]()
    
    private init() {}
    
    private func encodedCollection(named collectionName: String) -> [[String: Any]]? {
        return collections[collectionName]?.compactMap { $0.asDictionary }
    }
    
    /**
     Create a collection.
     - Parameter collectionNamed: Name of the collection.
     - Parameter includingUsers: List of users that are able to view the collection; defaults to none.
     - Parameter public: Is the collection global; defaults to false.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Returns: Void
    */
    public func create(
        collectionNamed collectionName: String,
        includingUsers users: [String] = [],
        public isPublic: Bool = false,
        _ completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        collections[collectionName] = []
        requestHandler.request(DataRouter.create(bucketName: collectionName, users: users, isPublic: isPublic)) {
            self.responseHandler.handleResponse(error: $0, response: $1, data: $2) { (error, _: Data?) in
                if error == nil {
                    self.collections[collectionName] = []
                }
                completion?(error)
            }
        }
    }
    
    public func add<C>(
        toCollection collectionName: String,
        value: C,
        public isPublic: Bool = false,
        _ completion: @escaping (_ error: Error?, _ collection: [C]?) -> Void)
        -> Void where C: Codable, C: Equatable
    {
        if collections[collectionName] == nil {
            collections[collectionName] = []
        }
        collections[collectionName]?.append(value)
        let e = encodedCollection(named: collectionName)
        print()
        requestHandler.request(DataRouter.write(bucketName: collectionName, key: collectionName, value: encodedCollection(named: collectionName))) {
            self.responseHandler.handleResponse(error: $0, response: $1, data: $2, atKey: "data.\(collectionName)", completion)
        }
    }
    
    public func remove<C>(
        fromCollection collectionName: String,
        value: C)
        -> Void where C: Codable, C: Equatable
    {
        
    }
    
    public func update<C>(
        inCollection collectionName: String,
        oldValue: C,
        newValue: C)
        -> Void where C: Codable, C: Equatable
    {
        
    }
    
    public func delete(
        collectionNamed collectionName: String)
        -> Void
    {
        
    }
}
