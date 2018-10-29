//
//  PlayPortalData.swift
//  Nimble
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
     - Parameter completion: The closure called when the request finishes.
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
        let host = PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment)
        let path = PlayPortalURLs.App.bucket
        
        guard let url = URL(string: host + path) else {
            completion?(PlayPortalError.API.failedToMakeRequest(message: "Unable to construct url for request."), nil)
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        let parameters: [String: Any] = [
            "id": bucketName,
            "users": users,
            "public": isPublic
        ]
        do {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
        } catch {
            completion?(PlayPortalError.API.failedToMakeRequest(message: "Unable to add body to request."), nil)
            return
        }
        
        //  Make request
        requestHandler.requestJSON(urlRequest) { error, json in
            guard error == nil
                , let json = json
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
        let host = PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment)
        let path = PlayPortalURLs.App.bucket
        
        guard let url = URL(string: host + path) else {
            completion?(PlayPortalError.API.failedToMakeRequest(message: "Unable to construct url for request."), nil)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "id": bucketName,
            "key": key,
            "value": value
        ]
        do {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
        } catch {
            completion?(PlayPortalError.API.failedToMakeRequest(message: "Unable to add body to request."), nil)
            return
        }
        
        //  Make request
        requestHandler.requestJSON(urlRequest) { error, json in
            guard error == nil
                , let json = json
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
        let host = PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment)
        let path = PlayPortalURLs.App.bucket
        
        var parameters: [String: String] = [
            "id": bucketName
        ]
        if let key = key {
            parameters["key"] = key
        }
        
        guard let url = URL(string: host + path)
            , let urlWithParams = url.with(queryParams: parameters)
            else {
                completion?(PlayPortalError.API.failedToMakeRequest(message: "Unable to construct url for request."), nil)
                return
        }
        
        var urlRequest = URLRequest(url: urlWithParams)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //  Make request
        requestHandler.requestJSON(urlRequest) { error, json in
            guard error == nil
                , let json = json
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
    */
    public func delete(
        fromBucket bucketName: String,
        atKey key: String,
        _ completion: ((_ error: Error?, _ bucket: PlayPortalDataBucket?) -> Void)?)
        -> Void
    {
        
        //  Create url request
        let host = PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment)
        let path = PlayPortalURLs.App.bucket
        
        guard let url = URL(string: host + path) else {
            completion?(PlayPortalError.API.failedToMakeRequest(message: "Unable to construct url for request."), nil)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let parameters: [String: Any?] = [
            "id": bucketName,
            "key": key,
            "value": nil
        ]
        do {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
        } catch {
            completion?(PlayPortalError.API.failedToMakeRequest(message: "Unable to add body to request."), nil)
            return
        }
        
        //  Make request
        requestHandler.requestJSON(urlRequest) { error, json in
            guard error == nil
                , let json = json
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
    */
    public func delete(bucketNamed bucketName: String, _ completion: ((_ error: Error?) -> Void)?) -> Void {
        
        //  Create url request
        let host = PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment)
        let path = PlayPortalURLs.App.bucket
        
        guard let url = URL(string: host + path) else {
            completion?(PlayPortalError.API.failedToMakeRequest(message: "Unable to construct url for request."))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        let parameters: [String: Any] = [
            "id": bucketName
        ]
        do {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
        } catch {
            completion?(PlayPortalError.API.failedToMakeRequest(message: "Unable to add body to request."))
        }
        
        //  Make request
        requestHandler.requestJSON(urlRequest) { error, _ in completion?(error) }
    }
}
