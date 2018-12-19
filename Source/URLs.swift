//
//  URLs.swift
//
//  Created by Lincoln Fraley on 10/24/18.
//

import Foundation

//  Namespace containing playPORTAl api available hosts and paths
enum URLs {
    
    static let sandboxHost = "https://sandbox.playportal.io"
    static let productionHost = "https://api.playportal.io"
    static let developHost = "https://develop-api.goplayportal.com"
    
    /**
     Get playPORTAL api host based on environment.
     
     - Paramenter forEnvironment: The playPORTAL environment currently being executed in.
     
     - Returns: The host.
     */
    static func getHost(forEnvironment environment: PlayPortalEnvironment) -> String {
        switch environment {
        case .sandbox:
            return URLs.sandboxHost
        case .develop:
            return URLs.developHost
        case .production:
            return URLs.productionHost
        }
    }
    
    enum OAuth {
        
        static let signIn = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/oauth/signin"
        static let token = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/oauth/token"
        static let logout = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/oauth/logout"
    }
    
    enum User {
        
        static let userProfile = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/user/v1/my/profile"
        static let friendProfiles = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/user/v1/my/friends"
        static let search = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/user/v1/search"
        static let randomSearch = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/user/v1/search/random"
    }
    
    enum Image {
        
        static let staticImage = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/image/v1/static"
    }
    
    enum Leaderboard {
        
        static let leaderboard = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/leaderboard/v1"
    }
    
    enum App {
        
        static let bucket = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/app/v1/bucket"
    }
}
