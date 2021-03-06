//
//  DXUserClient.swift
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation


//  Available user endpoints
class UserEndpoints: EndpointsBase {
  
  private static let base = UserEndpoints.host + "/user/v1"
  
  static let userProfile = UserEndpoints.base + "/my/profile"
  static let friendProfiles = UserEndpoints.base + "/my/friends"
  static let search = UserEndpoints.base + "/search"
  static let randomSearch = UserEndpoints.base + "/search/random"
}


//  Responsible for making requests to DX user api
public final class DXUserClient: DXHTTPClient {
  
  public static let shared = DXUserClient()
  
  private override init() {}
  
  override func onEvent() {
    print("calling on event in user")
  }
  
  /**
   Get currently authenticated user's DX profile.
   
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned on an unsuccessful request.
   - Parameter userProfile: The current user's profile returned on a successful request.
   
   - Returns: Void
   */
  public func getMyProfile(
    completion: @escaping (_ error: Error?, _ userProfile: DXProfile?) -> Void)
    -> Void
  {
    request(
      url: UserEndpoints.userProfile,
      method: .get,
      completionWithDecodableResult: completion
    )
  }
  
  /**
   Get currently authenticated user's DX friends' profiles.
   
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned on an unsuccessful request.
   - Parameter friendProfiles: The current user's friends' profiles returned on a successful request.
   
   - Returns: Void
   */
  public func getMyFriends(
    completion: @escaping (_ error: Error?, _ friendProfiles: [DXProfile]?) -> Void)
    -> Void
  {
    request(
      url: UserEndpoints.friendProfiles,
      method: .get,
      completionWithDecodableResult: completion
    )
  }
  
  /**
   Search for users by search term.
   - Parameter searchTerm: Term to search users by.
   - Parameter page: Supports pagination; at what page to get users from.
   - Paramter limit: How many entries to return.
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter users: The users returned for a successful request.
   */
  public func searchUsers(
    searchTerm: String,
    page: Int? = nil,
    limit: Int? = nil,
    completion: @escaping (_ error: Error?, _ users: [DXProfile]?) -> Void)
    -> Void
  {
    let queryParameters: [String: Any?] = [
      "term": searchTerm,
      "page": page,
      "limit": limit
    ]
    
    let handleSuccess: HandleSuccess<[DXProfile]> = { response, data in
      guard let json = (try JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
        , let docs = json["docs"]
        else {
          throw DXError.API.unableToDeserializeResult(message: "Unable to deserialize DXProfile array.")
      }
      
      let data = try JSONSerialization.data(withJSONObject: docs, options: [])
      return try self.defaultSuccessHandler(response: response, data: data)
    }
    
    request(
      url: UserEndpoints.search,
      method: .get,
      queryParameters: queryParameters,
      handleSuccess: handleSuccess,
      completionWithDecodableResult: completion
    )
  }
  
  /**
   Get a random number of users.
   - Parameter count: The number of users being requested.
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter users: The random users returned for a successful request.
   */
  public func getRandomUsers(
    count: Int,
    completion: @escaping (_ error: Error?, _ users: [DXProfile]?) -> Void)
    -> Void
  {
    let queryParameters = [
      "count": count
    ]
    
    request(
      url: UserEndpoints.randomSearch,
      method: .get,
      queryParameters: queryParameters,
      completionWithDecodableResult: completion
    )
  }
  
  /**
   Create an anonymous user that can be used in place of a user created through the DX signup flow.
   - Parameter clientId: Client id associated with the app.
   - Parameter dateOfBirth: Date string representing the user's date of birth. This is required to create the appropriate type of account for the user.
   - Parameter deviceToken: Device token used for push notifications for this user.
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter anonymousUser: The anonymous user created for a successful request.
   */
//  public func createAnonymousUser(
//    clientId: String,
//    dateOfBirth: String,
//    deviceToken: Data? = nil,
//    completion: @escaping (_ error: Error?, _ anonymousUser: DXProfile?) -> Void)
//    -> Void
//  {
//    let body: [String: Any?] = [
//      "clientId": clientId,
//      "dateOfBirth": dateOfBirth,
//      "deviceToken": deviceToken,
//      "anonymous": true
//    ]
//
//    let handleSuccess: HandleSuccess<DXProfile> = { response, data in
//      guard let accessToken = response.allHeaderFields["access_token"] as? String
//        , let refreshToken = response.allHeaderFields["refresh_token"] as? String
//        else {
//          throw DXError.API.unableToDeserializeResult(message: "Couldn't deserialize access or refresh token from response.")
//      }
//
//      DXUserClient.accessToken = accessToken
//      DXUserClient.refreshToken = refreshToken
//
//      return try self.defaultSuccessHandler(response: response, data: data)
//    }
//
//    request(
//      url: UserEndpoints.userProfile,
//      method: .put,
//      body: body,
//      createRequest: defaultRequestCreator,
//      handleSuccess: handleSuccess,
//      completionWithDecodableResult: completion
//    )
//  }
}
