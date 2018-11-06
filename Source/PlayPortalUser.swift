//
//  PlayPortalUser.swift
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation

//  Responsible for making requests to playPORTAL user api
public final class PlayPortalUser {
    
    //  MARK: - Properties
    
    //  Singleton instance
    public static let shared = PlayPortalUser()
    
    //  Handler for making api requests
    private var requestHandler: RequestHandler = globalRequestHandler
    
    
    //  MARK: - Initializers
    
    //  Private init to force use of singleton
    private init() {}
    
    
    //  MARK: - Methods
    
    /**
     Get currently authenticated user's playPORTAL profile.
     
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned on an unsuccessful request.
     - Parameter userProfile: The current user's profile returned on a successful request.
     
     - Returns: Void
     */
    public func getProfile(completion: @escaping (_ error: Error?, _ userProfile: PlayPortalProfile?) -> Void) -> Void {
        
        //  Create url request
        guard let urlRequest = URLRequest.from(
            method: "GET",
            andURL: PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + PlayPortalURLs.User.userProfile) else {
                completion(PlayPortalError.API.failedToMakeRequest(message: "Failed to construct 'URLRequest'."), nil)
                return
        }
        
        //  Make request
        requestHandler.request(urlRequest) { error, data in
            guard error == nil
                , let json = data?.toJSON
                else {
                    completion(error, nil)
                    return
            }
            do {
                let userProfile = try PlayPortalProfile(from: json)
                completion(nil, userProfile)
            } catch {
                completion(error, nil)
            }
        }
    }
    
    /**
     Get currently authenticated user's playPORTAL friends' profiles.
     
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned on an unsuccessful request.
     - Parameter friendProfiles: The current user's friends' profiles returned on a successful request.
     
     - Returns: Void
    */
    public func getFriendProfiles(completion: @escaping (_ error: Error?, _ friendProfiles: [PlayPortalProfile]?) -> Void) -> Void {
        
        //  Create url request
        guard let urlRequest = URLRequest.from(
            method: "GET",
            andURL: PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + PlayPortalURLs.User.friendProfiles) else {
                completion(PlayPortalError.API.failedToMakeRequest(message: "Failed to construct 'URLRequest'."), nil)
                return
        }
        
        //  Make request
        requestHandler.request(urlRequest) { error, data in
            guard error == nil
                , let jsonArray = data?.toJSONArray
                else {
                    completion(error, nil)
                    return
            }
            let friendProfiles = jsonArray.compactMap { try? PlayPortalProfile(from: $0) }
            completion(nil, friendProfiles)
        }
    }
}
