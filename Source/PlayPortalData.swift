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
        _ completion: ((_ error: Error?, _ bucket: [String: Any]?) -> Void)?)
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
        requestHandler.requestJSON(urlRequest) { error, bucket in
            guard error == nil
                , let bucket = bucket
                else {
                    completion?(error, nil)
                    return
            }
            completion?(nil, bucket)
        }
    }
    
    /**
     Write data to a bucket.
     
     - Parameter toBucket: The name of the bucket being written to.
     - Parameter atKey: At what key in the bucket the data will be written to.
     - Parameter withData: The data being added to the bucket.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     
     - Returns: Void
    */
    public func write(
        toBucket bucketName: String,
        atKey key: String,
        withData data: Any,
        _  completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        
    }
    
    /**
     Read data from a bucket.
     
     - Parameter fromBucket: Name of the bucket being read from.
     - Parameter atKey: If provided, will read data from the bucket at this key, otherwise the entire bucket is returned;
        defaults to nil.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter data: The data returned from the bucket for a successful request.
     
     - Returns: Void
    */
    public func read(
        fromBucket bucketName: String,
        atKey key: String? = nil,
        _ completion: ((_ error: Error?, _ data: Any?) -> Void)?)
        -> Void
    {
        
    }
    
    /**
     Delete data from a bucket.
     
     - Parameter fromBucket: Name of the bucket where data is being deleted from.
     - Parameter atKey: At what key to delete data.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
    */
    public func delete(
        fromBucket bucketName: String,
        atKey key: String,
        _ completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        
    }
}
