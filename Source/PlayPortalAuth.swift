//
//  PlayPortalAuth.swift
//  Nimble
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation


//  Available playPORTAL environments
public enum PlayPortalEnvironment: String {
    
    case sandbox = "SANDBOX"
    
    case production = "PRODUCTION"
}


//  Responsible for user authentication and token management
public final class PlayPortalAuth {
    
    //  MARK: - Properties
    
    //  Singleton instance
    public static let shared = PlayPortalAuth()
    
    //  App configuration
    private var environment = PlayPortalEnvironment.sandbox
    private var clientId = ""
    private var clientSecret = ""
    private var redirectURI = ""
    
    //  Flag that is checked before any sdk method is called to ensure that sdk is fully configured
    private var isConfigured = false
    
    
    //  MARK: - Initializers
    
    //  Private init to force use of singleton
    private init() {}
    
    
    //  MARK: - Methods
    
    /**
     Configures the sdk with an app's credentials, environment and redirect URI.
     
     
    */
    public func configure(
        forEnvironment environment: PlayPortalEnvironment,
        withClientId clientId: String,
        andClientSecret clientSecret: String,
        andRedirectURI redirectURI: String
    ) throws {
        //  Check for correct configuration inputs
        guard !clientId.isEmpty else { throw PlayPortalError.ConfigurationFailure.invalidClientId(message: "Client id must not be empty.") }
        guard !clientSecret.isEmpty else { throw PlayPortalError.ConfigurationFailure.invalidClientSecret(message: "Client secret must not be empty.") }
        guard !redirectURI.isEmpty else { throw PlayPortalError.ConfigurationFailure.invalidRedirectURI(message: "Redirect URI must not be empty.") }
        
        //  Set configuration
        PlayPortalAuth.shared.environment = environment
        PlayPortalAuth.shared.clientId = clientId
        PlayPortalAuth.shared.clientSecret = clientSecret
        PlayPortalAuth.shared.redirectURI = redirectURI
        
        //  SDK is fully configured
        PlayPortalAuth.shared.isConfigured = true
    }
    
    /**
     Check if user needs to authenticate. If not, return user, otherwise
    */
    public func isAuthenticated(_ completion: @escaping (_ isAuthenticated: Bool) -> Void) {
        completion(false)
    }
    
    public func handleOpen(url: URL) {
        
    }
}





















