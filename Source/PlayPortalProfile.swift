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
    public var firstName: String?
    public var lastName: String?
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
        
        case character = "Character"
        
        case community = "Community"
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
        guard let userId = json["userId"] as? String else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'userId' from JSON.")
        }
        guard let userType = PlayPortalProfile.userType(from: json) else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'userType' from JSON.")
        }
        guard let accountType = PlayPortalProfile.accountType(from: json) else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'accountType' from JSON.")
        }
        guard let handle = json["handle"] as? String else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'handle' from JSON.")
        }
        guard let country = json["country"] as? String else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'country' from JSON.")
        }
        
        self.userId = userId
        self.userType = userType
        self.accountType = accountType
        self.handle = handle
        self.country = country
        
        //  `character` and `community` `PlayPortalProfile.AccountTypes` don't have a `firstName` or `lastName` property
        if let firstName = json["firstName"] as? String {
            self.firstName = firstName
        }
        
        if let lastName = json["lastName"] as? String {
            self.lastName = lastName
        }
        
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
     
     - Parameter from: JSON representing playPORTAL profile.
     
     - Throws: If any of the properties are unable to be deserialized from the JSON.
     
     - Returns: `PlayPortalProfile` instance
     */
    internal static func factory(from json: [String: Any]) throws -> PlayPortalProfile {
        guard let accountType = PlayPortalProfile.accountType(from: json) else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'accountType' from JSON.")
        }
        return try PlayPortalProfile(from: json)
    }
    
    /**
     Create array of `PlayPortalProfile` instances from json array.
     
     - Parameter from: JSON array representing playPORTAL profile objects.
     
     - Throws: If any of the properties are unable to be deserialized from any of the JSON objects.
     
     - Returns: `PlayPortalProfile` instances
    */
    internal static func factory(fromArray jsonArray: [[String: Any]]) throws -> [PlayPortalProfile] {
        var profiles = [PlayPortalProfile]()
        for json in jsonArray {
            do {
                let profile = try PlayPortalProfile.factory(from: json)
                profiles.append(profile)
            }
        }
        return profiles
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




















