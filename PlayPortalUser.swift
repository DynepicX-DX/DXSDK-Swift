//
//  PlayPortalUser.swift
//  Nimble
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
     - Parameter error: Error returned on a failed request.
     - Parameter userProfile: The current user's profile returned on a successful request.
     
     - Returns: Void
    */
    public func getProfile(completion: @escaping (_ error: Error?, _ userProfile: PlayPortalProfile?) -> Void) -> Void {
        //  Create url request
        let host = PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment)
        let path = PlayPortalURLs.User.userProfile
        
        guard let url = URL(string: host + path) else {
            completion(PlayPortalError.API.failedToMakeRequest(message: "Unable to construct url for request."), nil)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        //  Make request
        requestHandler.requestJSON(urlRequest) { error, json in
            guard let json = json else {
                completion(PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize JSON from result."), nil)
                return 
            }
            do {
                let userProfile = try PlayPortalProfile.factory(from: json)
                completion(nil, userProfile)
            } catch {
                completion(error, nil)
            }
        }
    }
}
