//
//  RequestHandler.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 10/23/18.
//

internal let globalRequestHandler: RequestHandler = AlamofireRequestHandler.shared

//  Protocol to be adopted by class responsible for making requests to playPORTAL apis
internal protocol RequestHandler {
    
    //  MARK: - Properties
    
    var accessToken: String? { get }
    
    var refreshToken: String? { get }
    
    var isAuthenticated: Bool { get }
    
    
    //  MARK: - Methods
    
    /**
     Set tokens received through SSO.
     
     - Parameter accessToken: Access token received through SSO.
     - Parameter refreshToken: Refresh token received through SSO.
     
     - Returns: True if the tokens were set successfully
    */
    @discardableResult
    mutating func set(accessToken: String, andRefreshToken refreshToken: String) -> Bool
    
    /**
     Clear SSO tokens.
     
     - Returns: True if tokens were cleared successfully.
    */
    @discardableResult
    mutating func clearTokens() -> Bool
    
    /**
     Make request.
     
     - Parameter request: The request being made.
     - Parameter completion: The closure called after the request is made.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter json: The data returned for a successful request.
     
     - Returns: Void
     */
    func request(_ request: URLRequest, _ completion: ((_ error: Error?, _ data: Data?) -> Void)?) -> Void
}
