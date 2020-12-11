//
//  DXStudentClient.swift
//  KeychainSwift
//
//  Created by Lincoln Fraley on 11/19/19.
//

import Foundation

class StudentEndpoints: EndpointsBase {
  
  private static let base = StudentEndpoints.host + "/edu/v1/student"
  
  static let addStudent = StudentEndpoints.base + "/add"
  static let list = StudentEndpoints.base + "/list"
  static let remove = StudentEndpoints.base + "/remove"
  static let comment = StudentEndpoints.base + "/comment"
}

//  Responsible for making requests to student API
public final class DXStudentClient: DXHTTPClient {
  
  public static let shared = DXStudentClient()
  
  private override init() {}
  
  
  /**
   Adds an existing user to a class. The requesting user must be an account with teacher
   permissions.
   - Parameter studentId: User ID for the student you wish to add to the class.
   - Parameter classId: Group ID from a class. If omitted, the student is added to the default
      class of the requesting user.
   - Parameter completion: The closure invoked when the request finishes. Called with an
      `Error` argument if the request fails.
   */
//  public func addStudent(
//    studentId: String,
//    classId: String,
//    _ completion: ((_ error: Error?) -> Void)?
//  )
//  {
//    let body: [String: Any] = [
//      "studentId": studentId,
//      "classId": classId
//    ]
//    request(
//      url: StudentEndpoints.addStudent,
//      method: .post,
//      body: body,
//      completionWithNoResult: completion
//    )
//  }
  
  /**
   Retrieves students in the specified class.
   - Parameter classId: ID of class from which students are being requested.
   - Parameter limit: Page size to return.
   - Parameter page: Page of results to request.
   - Parameter completion: The closure invoked when the request finishes. Called with an
      `Error` argument if the request fails; otherwise, called with the requested students.
   */
//  public func getStudents(
//    classId: String,
//    limit: Int? = nil,
//    page: Int? = nil,
//    _ completion: @escaping (_ error: Error?, _ students: [DXProfile]?) -> Void)
//    -> Void
//  {
//    let params: [String: Any?] = [
//      "classId": classId,
//      "limit": limit,
//      "page": page,
//    ]
//
//    let handleSuccess: HandleSuccess<[DXProfile]> = { response, data in
//      guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//        let docs = json["docs"] else {
//          throw DXError.API.unableToDeserializeResult(message: "Unable to deserialize DXProfile array.")
//      }
//
//      let data = try JSONSerialization.data(withJSONObject: docs, options: [])
//      return try self.defaultSuccessHandler(response: response, data: data)
//    }
//
//    request(
//      url: StudentEndpoints.list,
//      method: .get,
//      queryParameters: params,
//      handleSuccess: handleSuccess,
//      completionWithDecodableResult: completion
//    )
//  }
  
  /**
   Removes a student from a specific class.
   - Parameter studentId: ID of the student to remove.
   - Parameter classId: The ID of the class to remove the student from.
   - Parameter completion: The closure invoked when the request finishes. Called with an
      `Error` argument if the request fails.
   */
//  public func removeStudent(
//    studentId: String,
//    classId: String,
//    _ completion: @escaping (_ error: Error?) -> Void)
//    -> Void
//  {
//    let body: [String: Any] = [
//      "studentId": studentId,
//      "classId": classId as Any
//    ]
//
//    request(
//      url: StudentEndpoints.remove,
//      method: .post,
//      body: body,
//      completionWithNoResult: completion
//    )
//  }
  
  /**
   Adds a comment about a student.
   - Parameter studentId: ID of the student to which this comment pertains.
   - Parameter classId: Id of the class to which this comment pertains.
   - Parameter text: Text of the comment.
   - Parameter lessonId: If the comment pertains to a specific lesson, specify it here.
   - Parameter completion: The closure invoked when the request finishes. Called with an
      `Error` argument if the request fails; otherwise, called with the newly created
      `DXStudentComment`.
   */
  public func addComment(
    studentId: String,
    classId: String,
    text: String,
    lessonId: String? = nil,
    _ completion: @escaping (_ error: Error?, _ comment: DXStudentComment?) -> Void)
    -> Void
  {
    let body: [String: Any] = [
      "studentId": studentId,
      "classId": classId,
      "text": text,
      "lessonId": lessonId,
    ]
    
    request(
      url: StudentEndpoints.comment,
      method: .post,
      body: body,
      completionWithDecodableResult: completion
    )
  }
  
  /**
   Retrieves comments about students based on the query provided.
   - Parameter studentId: ID of the student whose comments you would like to retrieve.
   - Parameter classId: ID of the class to retrieve comments for.
   - Parameter courseId: ID of the course to retrieve comments for.
   - Parameter lessonId: ID of the lesson to retrieve comments for.
   - Parameter completion: The closure invoked when the request finishes. Called with an
      `Error` argument if the request fails; otherwise, called with the requested comments.
   */
  public func getComments(
    studentId: String?,
    classId: String?,
    courseId: String?,
    lessonId: String?,
    _ completion: @escaping (_ error: Error?, _ comments: [DXStudentComment]?) -> Void)
    -> Void
  {
    let params: [String: Any] = [
      "studentId": studentId as Any,
      "classId": classId as Any,
      "courseId": courseId as Any,
      "lessonId": lessonId as Any,
    ]
    
    request(
      url: StudentEndpoints.comment,
      method: .get,
      queryParameters: params,
      completionWithDecodableResult: completion
    )
  }
}
