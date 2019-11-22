//
//  PlayPortalXAPIClient.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 11/22/19.
//

import Foundation

class XAPIEndpoints: EndpointsBase {
  
  private static let base = XAPIEndpoints.host + "/edu/v1/xapi"
  static let statement = XAPIEndpoints.base + "/statement"
}

//  Responsible for making requests to the xAPI API
public final class PlayPortalXAPIClient: PlayPortalHTTPClient {
  
  public static let shared = PlayPortalXAPIClient()
  
  
  /**
   Creates an xAPI statement.
   - Parameter actor: User ID of the actor performing the action.
   - Parameter verb: Action that the actor is carrying out on the object.
   - Parameter object: Target of the action the user is carrying out.
   - Parameter completion: The closure invoked when the request finishes. Called with an `Error`
      argument if the request fails.
   */
  public func createStatement(
    actor: String,
    verb: String,
    object: String,
    _ completion: @escaping (_ error: Error?) -> Void
    ) -> Void
  {
    let body: [String: Any] = [
      "actor": actor,
      "verb": verb,
      "object": object,
    ]
    
    request(
      url: XAPIEndpoints.statement,
      method: .post,
      body: body,
      completionWithNoResult: completion
    )
  }
}
