//
//  PlayPortalError.swift
//  Nimble
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation

public enum PlayPortalError {
    
    public enum ConfigurationFailure: Error {
        case notConfigured
        case invalidClientId(message: String)
        case invalidClientSecret(message: String)
        case invalidRedirectURI(message: String)
    }
}
