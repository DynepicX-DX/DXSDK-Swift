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
        case invalidConfiguration(message: String)
    }
    
    public enum SSO: Error {
        case ssoFailed(message: String)
    }
    
    public enum API: Error {
        
        case failedToMakeRequest(message: String)
        case requestFailed(errorCode: API.ErrorCode, description: String)
        case requestFailedForUnknownReason(message: String)
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
            
            
            //  MARK: - Methods
            
            /**
             Get a specific error code for a response.
             
             - Parameter for: The response containing the error code.
             
             - Returns: `ErrorCode` instance if the response contains a known error code, nil otherwise.
            */
            static internal func errorCode(for response: HTTPURLResponse) -> ErrorCode? {
                guard let errorCode = response.allHeaderFields["errorcode"] as? String
                    , let code = Int(errorCode)
                    else {
                        return nil
                }
                return ErrorCode(rawValue: code)
            }
        }
        
        /**
         Create a `PlayPortalError.API` error from a `HTTPURLResponse`'s headers.
         
         - Parameter from: The `HTTPURLResponse` instance used to create the error.
         
         - Returns: `PlayPortalError.API`
         */
        internal static func createError(from response: HTTPURLResponse) -> API {
            guard let errorCode = response.allHeaderFields["errorcode"] as? String
                , let code = Int(errorCode)
                , let description = response.allHeaderFields["errordescription"] as? String
                else {
                    return .requestFailedForUnknownReason(message: "Unable to parse 'errorcode' or 'errordescription' from response headers.")
            }
            guard let error = ErrorCode(rawValue: code) else {
                return .requestFailedForUnknownReason(message: "Error code '\(code)' did not match any known types.")
            }
            return .requestFailed(errorCode: error, description: description)
        }
    }
}
