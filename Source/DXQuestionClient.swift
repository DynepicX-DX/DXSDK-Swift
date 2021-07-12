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
            _ completion: @escaping (_ error: Error?, _ question: DXQuestion?) -> Void)
            -> Void
        {
            let params: [String: Any] = [
                "requestingUserId": requestingUserId,
                "courseId": courseId,
                "showRemoved": showRemoved?
            ]
            
            request(
                url: QuestionEndpoints.question,
                method: .get,
                queryParameters: params,
                completionWithDecodableResult: completion
            )
        }
        
        
    }
}
