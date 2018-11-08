//
//  PlayPortalUser.swift
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation


//  Available routes for playPORTAL user api
fileprivate enum UserRouter: URLRequestConvertible {
    
    case getUserProfile
    case getFriendProfiles
    
    func asURLRequest() -> URLRequest? {
        switch self {
        case .getUserProfile:
            return Router.get(url: PlayPortalURLs.User.userProfile, params: nil).asURLRequest()
        case .getFriendProfiles:
            return Router.get(url: PlayPortalURLs.User.friendProfiles, params: nil).asURLRequest()
        }
    }
}

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
        requestHandler.request(UserRouter.getUserProfile) { error, data in
            guard error == nil else {
                completion(error, nil)
                return
            }
            if let profile = data?.asDecodable(type: PlayPortalProfile.self) {
                completion(nil, profile)
            } else {
                completion(PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize data to 'PlayPortalProfile'."), nil)
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
        requestHandler.request(UserRouter.getFriendProfiles) { error, data in
            guard error == nil else {
                completion(error, nil)
                return
            }
//            let d = data!.toJSONArray
            
//            let friendProfiles = Array(data!).compactMap { $0.asDecodable(type(of: PlayPortalProfile.self ))}
//            completion(friendProfiles, nil)
//            let friendProfiles = jsonArray.compactMap { try? PlayPortalProfile(from: $0) }
//            completion(nil, friendProfiles)
        }
    }
}
