//
//  DXClassClient.swift
//  AwaitKit
//
//  Created by Lincoln Fraley on 11/19/19.
//

import Foundation

class ClassEndpoints: EndpointsBase {
  
  private static let base = ClassEndpoints.host + "/edu/v1/class"
  static let `class` = ClassEndpoints.base
  static let list = ClassEndpoints.base + "/list"
}

//  Responsible for making requests to class API
public final class DXClassClient: DXHTTPClient {
  
  public static let shared = DXClassClient()
  
  
  /**
   Creates a new class belonging to the requesting teacher. Teacher permissions must be added
   to the requesting account before this method can be called.
   - Parameter name: Plaintext name of the class.
   - Parameter courseId: ID of the course the class is taking.
   - Parameter completion: The closure invoked when the request finishes. Called with an
      `Error` argument if the request fails; otherwise, called with the newly created
      `DXClass`.
   */
  public func createClass(
    name: String,
    courseId: String? = nil,
    _ completion: @escaping (_ error: Error?, _ class: DXClass?) -> Void)
    -> Void
  {
    let body: [String: Any] = [
      "name": name,
      "courseId": courseId as Any
    ]
    request(
      url: ClassEndpoints.class,
      method: .put,
      body: body,
      completionWithDecodableResult: completion
    )
  }
  
  /**
   Retrieves all the classes belonging to the requesting teacher.
   - Parameter page: Results page to retrieve.
   - Parameter limit: Page size.
   - Parameter completion: The closure invoked when the request finishes. Called with an
      `Error` argument if the request fails; otherwise, called with the requested classes.
   */
  public func getClasses(
    page: Int? = nil,
    limit: Int? = nil,
    _ completion: @escaping (_ error: Error?, _ classes: [DXClass]?) -> Void)
    -> Void
  {
    let params: [String: Any?] = [
      "page": page,
      "limit": limit
    ]
    
    let handleSuccess: HandleSuccess<[DXClass]> = { response, data in
      guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
        let docs = json["docs"] else {
          throw DXError.API.unableToDeserializeResult(message: "Unable to deserialize DXClass array.")
      }
      
      let data = try JSONSerialization.data(withJSONObject: docs, options: [])
      return try self.defaultSuccessHandler(response: response, data: data)
    }
    
    request(
      url: ClassEndpoints.list,
      method: .get,
      queryParameters: params,
      handleSuccess: handleSuccess,
      completionWithDecodableResult: completion
    )
  }
}
