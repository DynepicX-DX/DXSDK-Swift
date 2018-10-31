//
//  PlayPortalData.swift
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation

//  Responsible for making requests to playPORTAL app api
public final class PlayPortalData {
    
    //  MARK: - Properties
    
    //  Singleton instance
    public static let shared = PlayPortalData()
    
    //  Handler for making api requests
    private var requestHandler: RequestHandler = globalRequestHandler
    
    
    //  MARK: - Initializers
    
    //  Private init to force use of singleton
    private init() {}
    
    
    //  MARK: - Methods
    
    /**
     Create a data bucket.
     
     - Parameter bucketName: Name given to the bucket.
     - Parameter includingUsers: Ids of users who will have access to the bucket.
     - Parameter isPublic: Indicates if the bucket is globally available; defaults to false.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter bucket: The newly created bucket.
     
     - Returns: Void
    */
    public func create(
        buckedNamed bucketName: String,
        includingUsers users: [String],
        isPublic: Bool = false,
        _ completion: ((_ error: Error?, _ bucket: PlayPortalDataBucket?) -> Void)?)
        -> Void
    {
        
        //  Create url request
        guard let urlRequest = URLRequest.from(
            method: "PUT",
            andURL: PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + PlayPortalURLs.App.bucket,
            andBody: [
                "id": bucketName,
                "users": users,
                "public": isPublic
            ]) else {
                completion?(PlayPortalError.API.failedToMakeRequest(message: "Failed to construct 'URLRequest'."), nil)
                return
        }
        
        //  Make request
        requestHandler.request(urlRequest) { error, data in
            guard error == nil
                , let json = data?.toJSON
                else {
                    completion?(error, nil)
                    return
            }
            do {
                let bucket = try PlayPortalDataBucket(from: json)
                completion?(nil, bucket)
            } catch {
                completion?(error, nil)
            }
        }
    }
    
    /**
     Write data to a bucket.
     
     - Parameter toBucket: The name of the bucket being written to.
     - Parameter atKey: At what key in the bucket the data will be written to. For nested keys, use a period-separated string eg. 'root.sub'.
     - Parameter withValue: The value being added to the bucket.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter bucket: The bucket the data was added to returned for a successful request.
     
     - Returns: Void
    */
    public func write(
        toBucket bucketName: String,
        atKey key: String,
        withValue value: Any,
        _  completion: ((_ error: Error?, _ bucket: PlayPortalDataBucket?) -> Void)?)
        -> Void
    {
        
        //  Create url request
        guard let urlRequest = URLRequest.from(
            method: "POST",
            andURL: PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + PlayPortalURLs.App.bucket,
            andBody: [
                "id": bucketName,
                "key": key,
                "value": value
            ]) else {
                completion?(PlayPortalError.API.failedToMakeRequest(message: "Failed to construct 'URLRequest'."), nil)
                return
        }
        
        //  Make request
        requestHandler.request(urlRequest) { error, data in
            guard error == nil
                , let json = data?.toJSON
                else {
                    completion?(error, nil)
                    return
            }
            do {
                let bucket = try PlayPortalDataBucket(from: json)
                completion?(nil, bucket)
            } catch {
                completion?(error, nil)
            }
        }
    }
    
    /**
     Read data from a bucket.
     
     - Parameter fromBucket: Name of the bucket being read from.
     - Parameter atKey: If provided, will read data from the bucket at this key, otherwise the entire bucket is returned;
        defaults to nil. For nested keys, use a period-separated string eg. 'root.sub'.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter bucket: A `PlayPortalDataBucket` instance containing the data at `atKey` returned for a successful request.
     
     - Returns: Void
    */
    public func read(
        fromBucket bucketName: String,
        atKey key: String? = nil,
        _ completion: ((_ error: Error?, _ value: PlayPortalDataBucket?) -> Void)?)
        -> Void
    {
        
        //  Create url request
        guard let urlRequest = URLRequest.from(
            method: "GET", andURL: PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + PlayPortalURLs.App.bucket,
            andQueryParams: [
                "id": bucketName
            ],
            andHeaders: [
                "Accept": "application/json"
            ]) else {
                completion?(PlayPortalError.API.failedToMakeRequest(message: "Failed to construct 'URLRequest'."), nil)
                return
        }
        
        //  Make request
        requestHandler.request(urlRequest) { error, data in
            guard error == nil
                , let json = data?.toJSON
                else {
                    completion?(error, nil)
                    return
            }
            do {
                let bucket = try PlayPortalDataBucket(from: json)
                completion?(nil, bucket)
            } catch {
                completion?(error, nil)
            }
        }
    }
    
    /**
     Delete data from a bucket.
     
     - Parameter fromBucket: Name of the bucket where data is being deleted from.
     - Parameter atKey: At what key to delete data.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter bucket: The updated bucket returned for a successful request.
     
     - Returns: Void
    */
    public func delete(
        fromBucket bucketName: String,
        atKey key: String,
        _ completion: ((_ error: Error?, _ bucket: PlayPortalDataBucket?) -> Void)?)
        -> Void
    {
        
        //  Create url request
        guard let urlRequest = URLRequest.from(
            method: "POST",
            andURL: PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + PlayPortalURLs.App.bucket,
            andBody: [
                "id": bucketName,
                "key": key,
                "value": nil
            ]) else {
                completion?(PlayPortalError.API.failedToMakeRequest(message: "Failed to construct 'URLRequest'."), nil)
                return
        }
        
        //  Make request
        requestHandler.request(urlRequest) { error, data in
            guard error == nil
                , let json = data?.toJSON
                else {
                    completion?(error, nil)
                    return
            }
            do {
                let bucket = try PlayPortalDataBucket(from: json)
                completion?(nil, bucket)
            } catch {
                completion?(error, nil)
            }
        }
    }
    
    /**
     Delete an entire bucket.
     
     - Parameter bucketNamed: The name of the bucket being deleted.
     - Parameter completion: The closure called when the request completes.
     - Parameter error: The error returned for an unsuccessful request.
     
     - Returns: Void
    */
    public func delete(bucketNamed bucketName: String, _ completion: ((_ error: Error?) -> Void)?) -> Void {
        
        //  Create url request
        guard let urlRequest = URLRequest.from(
            method: "DELETE", andURL: PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + PlayPortalURLs.App.bucket,
            andBody: [
                "id": bucketName
            ]) else {
                completion?(PlayPortalError.API.failedToMakeRequest(message: "Failed to construct 'URLRequest'."))
                return
        }
        
        //  Make request
        requestHandler.request(urlRequest) { error, _ in completion?(error) }
    }
}
