//
//  DXAssessmentClient.swift
//  Pods
//
//  Created by Lincoln Fraley on 1/8/20.
//

import Foundation

class AssessmentEndpoints: EndpointsBase {
  
  private static let base = AssessmentEndpoints.host + "/edu/v1/assessment"
  static let assessment = AssessmentEndpoints.base
  static let progress = AssessmentEndpoints.assessment + "/progress"
}

//  Responsible for making requests to the assessment API
public final class DXAssessmentClient: DXHTTPClient {
  
  public static let shared = DXAssessmentClient()
  
  /**
   Retrieves a single assessment by ID to be displayed to a user.
   - Parameter assessmentId: The ID of the requested assessment. This can be found when reading an
      assessment lesson. Corresponds to the `media` property of a `DXLesson`.
   - Parameter completion: The closure invoked when the request finishes. Called with an `Error`
      argument if the request fails; otherwise, called with a list of assessment questions that
      represents an assessment.
   */
  public func getAssessment(
    assessmentId: String,
    _ completion: @escaping (_ error: Error?, _ assessment: [DXAssessmentQuestion]?) -> Void)
    -> Void
  {
    let params: [String: Any] = [
      "assessmentId": assessmentId
    ]
    
    request(
      url: AssessmentEndpoints.assessment,
      method: .get,
      queryParameters: params,
      completionWithDecodableResult: completion
    )
  }
  
  /**
   Updates a student's answer for an assessment question. Returns the student's progress including
   their answers. Note that all questions in the assessment will be returned. Questions that the
   student has answered will have an "answer" field, questions that the student hasn't answered
   will have null for the "answer" and "correct" fields.
   - Parameter correct: Whether or not the student's answer is correct.
   - Parameter answer: Student's answer.
   - Parameter questionIndex: Integer index of the question in the assessment. This should match
      the index of the question returned in the assessment's array above.
   - Parameter classId: Assessments are graded on a class-by-class basis. Indicate which class you
      are reporting student answers on with this ID.
   - Parameter lessonId: ID of the assessment lesson.
   - Parameter studentId: Student who is being assessed. If omitted, defaults to the currently
      authenticated user.
   - Parameter completion: The closure invoked when the request finishes. Called with an `Error`
      argument if the request fails; otherwise, returns the student's lesson progress.
   */
  public func updateStudentAssessmentAnswers(
    correct: Bool,
    answer: String,
    questionIndex: Int,
    classId: String,
    lessonId: String,
    studentId: String? = nil,
    _ completion: @escaping (_ error: Error?, _ progress: DXLessonProgress?) -> Void
  ) -> Void
  {
    let body: [String: Any?] = [
      "correct": correct,
      "answer": answer,
      "questionIndex": questionIndex,
      "classId": classId,
      "lessonId": lessonId,
      "studentId": studentId,
    ]
    
    request(
      url: AssessmentEndpoints.progress,
      method: .post,
      body: body,
      completionWithDecodableResult: completion
    )
  }
}
