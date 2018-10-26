//
//  PlayPortalAuth.swift
//  Nimble
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation
import SafariServices


//  Available playPORTAL environments
public enum PlayPortalEnvironment: String {
    
    case sandbox = "SANDBOX"
    
    case develop = "DEVELOP"
    
    case production = "PRODUCTION"
}


//  Responsible for user authentication and token management
public final class PlayPortalAuth {
    
    //  MARK: - Properties
    
    //  Singleton instance
    public static let shared = PlayPortalAuth()
    
    //  App configuration
    internal var environment = PlayPortalEnvironment.sandbox
    private var clientId = ""
    private var clientSecret = ""
    private var redirectURI = ""
    
    //  Flag that is checked before any sdk method is called to ensure that sdk is fully configured
    private var isConfigured = false
    
    //  Completion that will be called once user is authenticated through auth flow.
    private var isAuthenticatedCompletion: ((_ error: Error?, _ userProfile: PlayPortalProfile?) -> Void)?
    
    //  Delegate used for login; will be passed any errors during SSO
    private weak var loginDelegate: PlayPortalLoginDelegate?
    
    //  Handler for making api requests
    private var requestHandler: RequestHandler = globalRequestHandler
    
    //  Maintain refrence to safari view controller so that it can be dismissed when SSO finishes
    private weak var safariViewController: SFSafariViewController?
    
    
    //  MARK: - Initializers
    
    //  Private init to force use of singleton
    private init() {}
    
    
    //  MARK: - Methods
    
    /**
     Configures the sdk with an app's credentials, environment and redirect URI.
     
     - Parameter forEnvironment: playPORTAL environment the sdk will make requests to.
     - Parameter withClientId: Client id associated with the app.
     - Parameter andClientSecret: Client secret associated with the app.
     - Parameter andRedirectURI: The redirect uri the playPORTAL SSO will use to return an authenticated user's tokens.
     
     - Throws: If any configuration arguments are invalid.
     
     - Returns: Void
     */
    public func configure(
        forEnvironment environment: PlayPortalEnvironment,
        withClientId clientId: String,
        andClientSecret clientSecret: String,
        andRedirectURI redirectURI: String
        ) throws -> Void {
        
        //  Check for correct configuration inputs
        guard !clientId.isEmpty else {
            throw PlayPortalError.Configuration.invalidConfiguration(message: "Client id must not be empty.")
        }
        guard !clientSecret.isEmpty else {
            throw PlayPortalError.Configuration.invalidConfiguration(message: "Client secret must not be empty.")
        }
        guard !redirectURI.isEmpty else {
            throw PlayPortalError.Configuration.invalidConfiguration(message: "Redirect URI must not be empty.")
        }
        
        //  Set configuration
        PlayPortalAuth.shared.environment = environment
        PlayPortalAuth.shared.clientId = clientId
        PlayPortalAuth.shared.clientSecret = clientSecret
        PlayPortalAuth.shared.redirectURI = redirectURI
        
        //  SDK is fully configured
        PlayPortalAuth.shared.isConfigured = true
    }
    
    /**
     Check if current user is authenticated. If not, SSO flow will need to be initiated.
     
     - Parameter completion: The closure called after requesting the user's profile.
     - Parameter error: The error returned from an unsuccessful request.
     - Parameter userProfile: The playPORTAL user profile returned from a successful request.
     
     - Returns: Void
     */
    public func isAuthenticated(_ completion: @escaping (_ error: Error?, _ userProfile: PlayPortalProfile?) -> Void) -> Void {
        if requestHandler.isAuthenticated {
            //  If authenticated, request current user's profile
            PlayPortalUser.shared.getProfile { error, userProfile in
                completion(error, userProfile)
            }
        } else {
            //  If not authenticated, set `isAuthenticatedCompletion` to be used after SSO flow finishes
            PlayPortalAuth.shared.isAuthenticatedCompletion = completion
            completion(nil, nil)
        }
    }
    
    /**
     Opens playPORTAL SSO.
     
     - Parameter delegate: PlayPortalLoginDelegate to handle any SSO errors.
     - Parameter from: UIViewController to present SFSafariViewController; defaults to topmost view controller.
     
     - Throws: If sdk is not fully configured or unable to create an SSO URL with query parameters.
     */
    internal func login(from viewController: UIViewController? = UIApplication.topMostViewController()) throws {
        
        //  Ensure sdk is configured before starting SSO.
        guard PlayPortalAuth.shared.isConfigured else {
            throw PlayPortalError.Configuration.notFullyConfigured
        }
        
        //  Construct sign in url
        let host = PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment)
        let path = PlayPortalURLs.OAuth.signIn
        let queryParams = [
            "client_id": PlayPortalAuth.shared.clientId,
            "client_secret": PlayPortalAuth.shared.clientSecret,
            "redirect_uri": PlayPortalAuth.shared.redirectURI,
            "response_type": "implicit",
            "state": "state"
        ]
        guard let baseURL = URL(string: host + path), let urlWithParams = baseURL.with(queryParams: queryParams) else {
            throw PlayPortalError.SSO.unableToOpenSSO(message: "Could not construct SSO SignIn URL.")
        }
        
        //  Open SSO sign in with safari view controller
        safariViewController = SFSafariViewController(url: urlWithParams)
        safariViewController!.modalTransitionStyle = .coverVertical
        viewController?.present(safariViewController!, animated: true, completion: nil)
    }
    
    /**
     This function must be invoked in the AppDelegate's application(_:handleOpen:) method to handle a successful redirect from the playPORTAL SSO.
     
     - Parameters url: The redirect URI called by playPORTAL SSO containing a user's tokens.
     
     - Throws: If unable to extract parameters from redirect url.
     
     - Returns: Void
     */
    public func open(url: URL) throws -> Void {
        
        //  Dismiss safari view controller
        defer {
            safariViewController?.dismiss(animated: true, completion: nil)
        }
        
        //  Extract tokens
        guard let accessToken = url.getParameter(for: "access_token") else {
            throw PlayPortalError.SSO.parameterNotInRedirect(message: "Could not extract access token from redirect uri.")
        }
        guard let refreshToken = url.getParameter(for: "refresh_token") else {
            throw PlayPortalError.SSO.parameterNotInRedirect(message: "Could not extract refresh token from redirect uri.")
        }
        
        requestHandler.accessToken = accessToken
        requestHandler.refreshToken = refreshToken
        
        //  Request current user's profile
        PlayPortalUser.shared.getProfile { error, userProfile in
            PlayPortalAuth.shared.isAuthenticatedCompletion?(error, userProfile)
        }
    }
    
    /**
     Called when a refresh is required.
     
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned on an unsuccessful request.
     - Parameter accessToken: The new access token returned on a successful request.
     - Parameter refreshToken: The new refresh token returned on a successful request.
     
     - Returns: Void
     */
    internal func refresh(completion: @escaping (_ error: Error?, _ accessToken: String?, _ refreshToken: String?) -> Void) -> Void {
        
        //  Create url request
        let host = PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment)
        let path = PlayPortalURLs.OAuth.token
        
        guard let url = URL(string: host + path)
            , let accessToken = requestHandler.accessToken
            , let refreshToken = requestHandler.refreshToken
            else {
                completion(PlayPortalError.API.failedToMakeRequest(message: "Unable to construct url for request."), nil, nil)
                return
        }
        let queryParams: [String: String] = [
            "access_token": accessToken,
            "refresh_token": refreshToken,
            "client_id": PlayPortalAuth.shared.clientId,
            "client_secret": PlayPortalAuth.shared.clientSecret,
            "grant_type": "refresh_token"
        ]
        guard let baseURL = URL(string: host + path), let urlWithParams = baseURL.with(queryParams: queryParams) else {
            completion(PlayPortalError.API.failedToMakeRequest(message: "Unable to construct url for request."), nil, nil)
            return
        }
        
        var urlRequest = URLRequest(url: urlWithParams)
        urlRequest.httpMethod = "POST"
        
        //  Make request
        requestHandler.requestJSON(urlRequest) { error, json in
            guard let json = json
                , let accessToken = json["access_token"] as? String
                , let refreshToken = json["refresh_token"] as? String
                else {
                    completion(PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize JSON from result."), nil, nil)
                    return
            }
            completion(nil, accessToken, refreshToken)
        }
    }
}
