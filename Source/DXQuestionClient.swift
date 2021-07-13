//
//  DXQuestionClient.swift
//  DXSDK-Swift
//
//  Created by Joshua Paulsen on 7/12/21.
//  Copyright © 2021 Lincoln Fraley. All rights reserved.
//

import Foundation

//Available question endpoints
class QuestionEndpoints : EndpointsBase {
    
    private static let base = QuestionEndpoints.host + "/edu/v1/question/"
    static let question = QuestionEndpoints.base


}


//  Responsible for making requests to DX question api
public final class DXQuestionClient: DXHTTPClient {
  
  public static let shared = DXQuestionClient()
  
  private override init() {}
  
    /**
     - Parameter requestingUserId: Id of the user attempting to access the question bank..
     - Parameter courseId: Id of the course being queried for questions.
     - Parameter showRemoved: Show removed question.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error`
     argument if the request fails; otherwise, called with`DXQuestion`.
     */
  public func getQuestionsById(
    requestingUserId: String,
    courseId: String,
    showRemoved: String? = nil,
    _ completion: @escaping (_ error: Error?, _ questions: [DXQuestion]?) -> Void)
    -> Void
{
    let params: [String: Any] = [
        "requestingUserId": requestingUserId,
        "courseId": courseId,
        "showRemoved": showRemoved as Any,
    ]
    
    let handleSuccess: HandleSuccess<[DXQuestion]> = { response, data in
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let docs = json["docs"] else {
                throw DXError.API.unableToDeserializeResult(message: "Unable to deserialize DXQuestion array.")
        }
        
        let data = try JSONSerialization.data(withJSONObject: docs, options: [])
        return try self.defaultSuccessHandler(response: response, data: data)
    }
    
    request(
        url: QuestionEndpoints.question,
        method: .get,
        queryParameters: params,
        handleSuccess: handleSuccess,
        completionWithDecodableResult: completion
    )
  }
}
