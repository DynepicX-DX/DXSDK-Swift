//
//  DXProfile.swift
//
//  Created by Lincoln Fraley on 10/24/18.
//

import Foundation

//  Struct representing a DX user's profile.
public struct DXProfile: Codable {
  
  public let userId: String
  public let userType: UserType
  public let accountType: AccountType
  public let handle: String
  public var firstName: String?
  public var lastName: String?
  public var profilePic: String?
  public var coverPhoto: String?
  public let country: String
  private var _anonymous: Bool?
  public var anonymous: Bool {
    return _anonymous ?? false
  }
  
  private enum CodingKeys: String, CodingKey {
    case userId
    case userType
    case accountType
    case handle
    case firstName
    case lastName
    case profilePic
    case coverPhoto
    case country
    case _anonymous = "anonymous"
  }
  
  private init() {
    fatalError("`DXProfile` instances should only be initialized by decoding.")
  }
  
  //  Represents possible DX user types
  public enum UserType: String, Codable {
    case adult = "adult"
    case child = "child"
    case teenMinor = "teen-minor"
  }
  
  //  Represents possible DX account types
  public enum AccountType: String, Codable {
    case parent = "Parent"
    case kid = "Kid"
    case adult = "Adult"
    case character = "Character"
    case community = "Community"
  }
}

extension DXProfile: Equatable {
  
  public static func ==(lhs: DXProfile, rhs: DXProfile) -> Bool {
    return lhs.userId == rhs.userId
  }
}
