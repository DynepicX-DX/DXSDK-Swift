//
//  PlayPortalProfile.swift
//
//  Created by Lincoln Fraley on 10/24/18.
//

import Foundation

//  Class representing a playPORTAL user's profile.
public struct PlayPortalProfile {
    
    //  MARK: - Properties
    
    public let userId: String
    public let userType: UserType
    public let accountType: AccountType
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
     
     - Returns: `PlayPortalProfile` instance.
     */
    internal init(from json: [String: Any]) throws {
        
        //  Deserialize properties
        guard let userId = json["userId"] as? String else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'userId' from JSON.")
        }
        guard let userTypeRawValue = json["userType"] as? String
            , let userType = UserType.init(rawValue: userTypeRawValue) else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'userType' from JSON.")
        }
        guard let accountTypeRawValue = json["accountType"] as? String
            , let accountType = AccountType.init(rawValue: accountTypeRawValue) else {
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
}
