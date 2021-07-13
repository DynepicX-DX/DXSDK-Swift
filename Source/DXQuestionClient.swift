//
//  DXQuestionClient.swift
//  DXSDK-Swift
//
//  Created by Joshua Paulsen on 7/12/21.
//  Copyright © 2021 Lincoln Fraley. All rights reserved.
//

import Foundation

class QuestionEndpoints : EndpointsBase {
    
    private static let base = QuestionEndpoints.host + "/edu/v1/question/"
    static let question = QuestionEndpoints.base
    
    public final class DXQuestionClient: DXHTTPClient {
        
        public static let shared = DXQuestionClient()

        private override init() {}

        /**
         This endpoint allows an instructor or a course manager to get all questions for a specific course.
         - Parameter order: Lessons must be completed in a specific order, specified with this
         parameter.
         - Parameter requestingUserId: ID of the course to add the lesson to.
         - Parameter courseId: A link to the lesson's content.
         - Parameter showRemoved: Short name for the course.
         */
        
        public func getQuestionByCourseId(
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
                completionWithDecodableResult: completion
            )
        }
        
        
    }
}
