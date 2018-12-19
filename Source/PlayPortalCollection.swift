//
//  PlayPortalCollection.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 11/8/18.
//

import Foundation

public typealias CollectionType = Codable & Equatable

//  Responsible for 'collection' requests to playPORTAL data api
public final class PlayPortalCollection {
    
    public static let shared = PlayPortalCollection()
    private var collections = Synchronized<[String: [Any]]>(value: [:])
    
    private init() { }
    
    deinit {
        EventHandler.shared.unsubscribe(self)
    }
    
    //  TODO: create an extension for this
    private func encode<C: CollectionType>(_ collection: [C]) -> [[String: Any]] {
        return collection.compactMap { $0.asDictionary }
    }
    
    /**
     Create a collection.
     - Parameter collectionNamed: Name of the collection.
     - Parameter includingUsers: List of users that are able to view the collection; defaults to none.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Returns: Void
    */
    public func create(
        collectionNamed collectionName: String,
        includingUsers users: [String] = [],
//        public isPublic: Bool = false,
        _ completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        let request = DataRouter.create(bucketName: collectionName, users: users, isPublic: false)
        RequestHandler.shared.request(request) { error in
            if error == nil {
                self.collections.value[collectionName] = []
            }
            completion?(error)
        }
    }
    
    /**
     Read a collection.
     - Parameter fromCollection: The collection to be read.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: Error returned for an unsuccessful request.
     - Parameter collection: The collection returned for a successful request.
     - Returns: Void
    */
    public func read<C: CollectionType>(
        fromCollection collectionName: String,
        _ completion: @escaping (_ error: Error?, _ collection: [C]?) -> Void)
        -> Void
    {
        let request = DataRouter.read(bucketName: collectionName, key: collectionName)
        RequestHandler.shared.request(request) { (error, collection: [C]?) in
            if error == nil {
                self.collections.value[collectionName] = collection
            }
            completion(error, collection)
        }
    }
    
    /**
     Add element to a collection.
     - Parameter toCollection: Name of the collection.
     - Parameter element: The element being added.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter collection: The collection returned for a successful request.
     - Returns: Void
    */
    public func add<C: CollectionType>(
        toCollection collectionName: String,
        element: C,
        _ completion: @escaping (_ error: Error?, _ collection: [C]?) -> Void)
        -> Void
    {
        guard let collection = collections.value[collectionName] else {
            preconditionFailure("Cannot perform operations on a collection that hasn't been created.")
        }
        precondition(collection.matches(type: C.self), "Elements in collection `\(collectionName)` do not match type \(type(of: C.self)).")
        
        let updatedCollection: [C] = collection + [element] as! [C]
        let request = DataRouter.write(bucketName: collectionName, key: collectionName, value: encode(updatedCollection))
        RequestHandler.shared.request(request) { (error, collection: [C]?) in
            if error == nil {
                self.collections.value[collectionName] = collection
            }
            completion(error, collection)
        }
    }
    
    /**
     Remove element from collection.
     - Parameter fromCollection: The name of the collection being updated.
     - Paramter value: The element to be removed.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter collection: The collection returned for a successful request.
     - Returns: Void
    */
    public func remove<C: CollectionType>(
        fromCollection collectionName: String,
        value: C,
        _ completion: @escaping (_ error: Error?, _ collection: [C]?) -> Void)
        -> Void
    {
        guard let collection = collections.value[collectionName] else {
            preconditionFailure("Cannot perform operations on a collection that hasn't been created.")
        }
        precondition(collection.matches(type: C.self), "Elements in collection `\(collectionName)` do not match type \(type(of: C.self)).")
        
        let updatedCollection: [C] = (collection as! [C]).filter { $0 != value }
        let request = DataRouter.write(bucketName: collectionName, key: collectionName, value: encode(updatedCollection))
        RequestHandler.shared.request(request) { (error, collection: [C]?) in
            if error == nil {
                self.collections.value[collectionName] = collection
            }
            completion(error, collection)
        }
    }
    
    /**
     Update first element in a collection that matches `oldValue` with `newValue`.
     - Parameter inCollection: The collection being updated.
     - Parameter oldValue: The element being replaced.
     - Parameter newValue: The element being added.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter collection: The collection returned for a successful request.
     - Returns: Void
    */
    public func update<C: CollectionType>(
        inCollection collectionName: String,
        oldValue: C,
        newValue: C,
        _ completion: @escaping (_ error: Error?, _ collection: [C]?) -> Void)
        -> Void
    {
        guard let collection = collections.value[collectionName] else {
            preconditionFailure("Cannot perform operations on a collection that hasn't been created.")
        }
        precondition(collection.matches(type: C.self), "Elements in collection `\(collectionName)` do not match type \(type(of: C.self)).")
        
        var updatedCollection: [C] = collection as! [C]
        guard let index = updatedCollection.firstIndex(of: oldValue) else {
            completion(nil, updatedCollection)
            return
        }
        
        updatedCollection[index] = newValue
        let request = DataRouter.write(bucketName: collectionName, key: collectionName, value: encode(updatedCollection))
        RequestHandler.shared.request(request) { (error, collection: [C]?) in
            if error == nil {
                self.collections.value[collectionName] = collection
            }
            completion(error, collection)
        }
    }
    
    /**
     Delete a collection.
     - Parameter collectionNamed: Name of the collection to be deleted.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Returns: Void
    */
    public func delete(
        collectionNamed collectionName: String,
        _ completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        RequestHandler.shared.request(DataRouter.delete(bucketName: collectionName)) { error in
            if error == nil {
                self.collections.value[collectionName] = nil
            }
            completion?(error)
        }
    }
}

extension PlayPortalCollection: EventSubscriber {
    
    func on(event: Event) {
        switch event {
        case .loggedOut:
            collections = Synchronized<[String: [Any]]>(value: [:])
        default:
            break
        }
    }
}
