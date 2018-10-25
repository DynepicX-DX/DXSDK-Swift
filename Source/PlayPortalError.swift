//
//  PlayPortalError.swift
//  Nimble
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation

public enum PlayPortalError {
    
    public enum Configuration: Error {
        case notFullyConfigured
        case invalidClientId(message: String)
        case invalidClientSecret(message: String)
        case invalidRedirectURI(message: String)
    }
    
    public enum SSO: Error {
        case unableToOpenSSO(message: String)
        case parameterNotInRedirect(message: String)
    }
    
    public enum API: Error {
        
        //  Miscellaneous
        case unableToConstructURL
        case unableToCreateError(message: String)
        
        case requestFailed(error: API.ErrorCode, description: String)
        
        case unableToDeserializeResult(message: String)
        
        
        //  Error codes
        public enum ErrorCode: Int {
            
            //  400 - Bad request
            case unspecifiedBadRequest = 4000
            case parameterMissing
            case duplicateResource
            case validationError
            case incorrectUserType
            case parametersUnusable
            case actionImpossible
            case aboveDataLimit
            case tokenAlreadyUsed
            case contentFlaggedForModeration
            
            //  401 - Unauthorized
            case tokenRefreshRequired = 4010
            case invalidCredentials
            case apiKeyInvalid
            case accountUnderModeration
            case insufficientPermissions
            case authorizationCodeMalformed
            case authorizationMissing
            case requestedScopeNotRegistered
            case notificationsNotEnabledForDevice
            
            //  403 - Forbidden
            case userAttemptedUnathorizedAction = 4032
            case authorizationRequestMissingParameter
            case authorizationTokenInvalid
            case anonymousUserAttemptedUnauthorizedAction
            
            //  404 - Not Found
            case resourceNotFound = 4042
            
            //  409 - Conflict
            case alreadyExists = 4091
            
            //  410 - Gone
            case raffleEnded = 4101
            case raffleNotStarted
            
            //  429 - Raffle
            case tooManyRaffleRequests = 4291
            
            //  451 - Privacy Policy
            case adultParentOutdatedPrivacyPolicy = 4511
            case kidOutdatedPrivacyPolicy
            
            //  500 - Internal Server Error
            case unspecifiedInternalError = 5000
            case failedToSaveData
            case failedToUpdateData
            case internalProcessFailed
            case internalDataMissingOrCorrupted
            case partnerProcessFailed
            
            // 505 - HTTP Version Not Supported
            case appVersionNotSupported = 5051
        }
        
        /**
         Create a `PlayPortalError.API` error from a `HTTPURLResponse`'s headers.
         
         - Parameter from: The `HTTPURLResponse` instance used to create the error.
         
         - Returns: `PlayPortalError.API`
        */
        internal static func createError(from response: HTTPURLResponse) -> PlayPortalError.API {
            guard let errorCode = response.allHeaderFields["errorcode"] as? String
                , let code = Int(errorCode)
                , let description = response.allHeaderFields["errordescription"] as? String
                else { return .unableToCreateError(message: "Unable to parse 'errorcode' or 'errordescription' from response headers.") }
            guard let error = ErrorCode(rawValue: code) else { return .unableToCreateError(message: "Error code '\(code)' did not match any known types.") }
            return .requestFailed(error: error, description: description)
        }
    }
}
