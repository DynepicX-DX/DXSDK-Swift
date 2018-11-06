//
//  PlayPortalURLs.swift
//
//  Created by Lincoln Fraley on 10/24/18.
//

import Foundation

//  Struct containing playPORTAl api available hosts and paths
struct PlayPortalURLs {
    
    //  MARK: - Properties
    
    static let sandboxHost = "https://sandbox.playportal.io"
    static let productionHost = "https://api.playportal.io"
    static let developHost = "https://develop-api.goplayportal.com"
    
    
    //  MARK: - Initializers
    
    private init() {}
    
    
    //  MARK: - Methods
    
    /**
     Get playPORTAL api host based on environment.
     
     - Paramenter forEnvironment: The playPORTAL environment currently being executed in.
     
     - Returns: The host.
     */
    static func getHost(forEnvironment environment: PlayPortalEnvironment) -> String {
        switch environment {
        case .sandbox:
            return PlayPortalURLs.sandboxHost
        case .develop:
            return PlayPortalURLs.developHost
        case .production:
            return PlayPortalURLs.productionHost
        }
    }
    
    
    //  MARK: - Internal structs for representing available apis and their endpoints
    
    struct OAuth {
        
        private init() {}
        
        static let signIn = "/oauth/signin"
        static let token = "/oauth/token"
        static let logout = "/oauth/logout"
    }
    
    struct User {
        
        private init() {}
        
        static let userProfile = "/user/v1/my/profile"
        static let friendProfiles = "/user/v1/my/friends"
    }
    
    struct Image {
        
        private init() {}
        
        static let staticImage = "/image/v1/static"
    }
    
    struct Leaderboard {
        
        private init() {}
        
        static let leaderboard = "/leaderboard/v1"
    }
    
    struct App {
        
        private init() {}
        
        internal static let bucket = "/app/v1/bucket"
    }
}
