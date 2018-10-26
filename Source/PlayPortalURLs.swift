//
//  PlayPortalURLs.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 10/24/18.
//

import Foundation

//  Struct containing playPORTAl api available hosts and paths
internal struct PlayPortalURLs {
    
    //  MARK: - Properties
    
    internal static let sandboxHost = "https://sandbox.playportal.io"
    
    internal static let productionHost = "https://api.playportal.io"
    
    internal static let developHost = "https://develop-api.goplayportal.com"
    
    
    //  MARK: - Initializers
    
    private init() {}
    
    
    //  MARK: - Methods
    
    /**
     Get playPORTAL api host based on environment.
     
     - Paramenter forEnvironment: The playPORTAL environment currently being executed in.
     
     - Returns: The host.
     */
    internal static func getHost(forEnvironment environment: PlayPortalEnvironment) -> String {
        switch environment {
        case .sandbox:
            return PlayPortalURLs.sandboxHost
        case .develop:
            return PlayPortalURLs.developHost
        case .production:
            return PlayPortalURLs.productionHost
        }
    }
    
    
    //  MARK: - Internal structs for available apis
    
    internal struct OAuth {
        
        //  MARK: - Initializers
        
        private init() {}
        
        
        //  MARK: - Properties
        
        internal static let signIn = "/oauth/signin"
        
        internal static let token = "/oauth/token"
    }
    
    internal struct User {
        
        //  MARK: - Initializers
        
        private init() {}
        
        
        //  MARK: - Properties
        
        internal static let userProfile = "/user/v1/my/profile"
    }
    
    internal struct Image {
        
        //  MARK: - Initializers
        
        private init() {}
        
        
        //  MARK: - Properties
        
        internal static let staticImage = "/image/v1/static"
    }
}
