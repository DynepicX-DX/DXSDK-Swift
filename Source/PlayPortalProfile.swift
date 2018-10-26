//
//  PlayPortalProfile.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 10/24/18.
//

import Foundation

//  Class representing a playPORTAL user's profile.
open class PlayPortalProfile {
    
    //  MARK: - Properties
    
    public let userId: String
    public let userType: PlayPortalProfile.UserType
    public let accountType: PlayPortalProfile.AccountType
    public let handle: String
    public let firstName: String
    public let lastName: String
    public var profilePic: String?
    public var coverPhoto: String?
    public let country: String
    
    
    //  MARK: - Enums
    
    //  Enum representing possible playPORTAL user types
    public enum UserType: String {
        
        case adult = "adult"
        
        case child = "child"
        
        case teenMinor = "teen-minor"
    }
    
    //  Enum representing possible playPORTAL account types
    public enum AccountType: String {
        
        case parent = "Parent"
        
        case kid = "Kid"
        
        case adult = "Adult"
    }
    
    
    //  MARK: - Initializers
    
    /**
     Create profile from json.
     
     - Parameter from: The JSON object representing the user's profile.
     
     - Throws: If any of the properties are unable to be deserialized from the JSON.
     
     - Returns: `PlayPortalProfile`
     */
    public init(from json: [String: Any]) throws {
        
        //  Deserialize all properties
        guard let userId = json["userId"] as? String
            , let userType = PlayPortalProfile.userType(from: json)
            , let accountType = PlayPortalProfile.accountType(from: json)
            , let handle = json["handle"] as? String
            , let firstName = json["firstName"] as? String
            , let lastName = json["lastName"] as? String
            , let country = json["country"] as? String
            else {
                throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize one or more properties from JSON.")
        }
        
        self.userId = userId
        self.userType = userType
        self.accountType = accountType
        self.handle = handle
        self.firstName = firstName
        self.lastName = lastName
        self.country = country
        
        //  Profile pic and cover photo may be nil
        if let profilePic = json["profilePic"] as? String? {
            self.profilePic = profilePic
        }
        
        if let coverPhoto = json["coverPhoto"] as? String? {
            self.coverPhoto = coverPhoto
        }
    }
    
    /**
     Create `PlayPortalProfile` based on account type.
     
     - Throws: If any of the properties are unable to be deserialized from the JSON.
     
     - Returns: `PlayPortalProfile`
     */
    internal static func factory(from json: [String: Any]) throws -> PlayPortalProfile {
        guard let accountType = PlayPortalProfile.accountType(from: json) else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize account type from JSON.")
        }
        
        return try PlayPortalProfile(from: json)
    }
    
    /**
     Helper function to get account type from JSON.
     
     - Parameter from: JSON to extract account type from.
     
     - Returns: `PlayPortalProfile.AccountType` if able to extract account type, nil otherwise.
     */
    private static func accountType(from json: [String: Any]) -> PlayPortalProfile.AccountType? {
        guard let accountTypeRawValue = json["accountType"] as? String else {
            return nil
        }
        return PlayPortalProfile.AccountType.init(rawValue: accountTypeRawValue)
    }
    
    /**
     Helper function to get account user from JSON.
     
     - Parameter from: JSON to extract user type from.
     
     - Returns: `PlayPortalProfile.UserType` if able to extract user type, nil otherwise.
     */
    private static func userType(from json: [String: Any]) -> PlayPortalProfile.UserType? {
        guard let userTypeRawValue = json["userType"] as? String else {
            return nil
        }
        return PlayPortalProfile.UserType.init(rawValue: userTypeRawValue)
    }
}




















