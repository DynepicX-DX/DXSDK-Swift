//
//  PlayPortalCourseClient.swift
//  KeychainSwift
//
//  Created by Lincoln Fraley on 11/19/19.
//

import Foundation

class CourseEndpoints: EndpointsBase {
    
    private static let base = CourseEndpoints.host + "/edu/v1/course"
    static let course = CourseEndpoints.base
    static let list = CourseEndpoints.base + "/list"
    static let objectives = CourseEndpoints.course + "/objectives"
    static let performance = CourseEndpoints.objectives + "/performance"
}

//  Responsible for making requests to course API
public final class PlayPortalCourseClient: PlayPortalHTTPClient {
    
    public static let shared = PlayPortalCourseClient()
    
    private override init() {}
    
    
    /**
     Creates a new course.
     - Parameter name: Short name for the course.
     - Parameter description: A long-form description of the course.
     - Parameter profilePic: 64-bit encoded small square JPG to be used as a profile picture
     (or icon) for the course.
     - Parameter coverPhoto: 64-bit encoded wide-resolution JPG to be used as a cover photo for the
     course.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error`
     argument if the request fails; otherwise, called with the newly created `PlayPortalCourse`.
     */
    public func createCourse(
        name: String,
        description: String,
        profilePic: String,
        coverPhoto: String? = nil,
        _ completion: @escaping (_ error: Error?, _ course: PlayPortalCourse?) -> Void)
        -> Void
    {
        let body: [String: Any] = [
            "name": name,
            "description": description,
            "profilePic": profilePic,
            "coverPhoto": coverPhoto as Any
        ]
        request(
            url: CourseEndpoints.course,
            method: .put,
            body: body,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Retrieves a single course by ID.
     - Parameter courseId: The ID of the requested course.
     - Parameter completion: Closure invoked when the request finishes. Called with
     an `Error` argument if the request fails; otherwise, called with the newly
     created `PlayPortalCourse`.
     */
    public func getCourse(
        courseId: String,
        _ completion: @escaping (_ error: Error?, _ course: PlayPortalCourse?) -> Void)
        -> Void
    {
        let params: [String: Any] = [
            "courseId": courseId
        ]
        request(
            url: CourseEndpoints.course,
            method: .get,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Retrieves all courses.
     - Parameter limit: Page size.
     - Parameter page: Results page to return.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error`
     argument if the request fails; otherwise, called with the requested courses.
     */
    public func getAllCourses(
        limit: Int? = nil,
        page: Int? = nil,
        completion: @escaping (_ error: Error?, _ courses: [PlayPortalCourse]?) -> Void
    )
    {
        let params: [String: Any?] = [
            "limit": limit,
            "page": page
        ]
        
        let handleSuccess: HandleSuccess<[PlayPortalCourse]> = { response, data in
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let docs = json["docs"] else {
                    throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize PlayPortalCourse array.")
            }
            
            let data = try JSONSerialization.data(withJSONObject: docs, options: [])
            return try self.defaultSuccessHandler(response: response, data: data)
        }
        
        request(
            url: CourseEndpoints.list,
            method: .get,
            queryParameters: params,
            handleSuccess: handleSuccess,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Retrieves a courses objectives along with a student's performance on the objectives.
     - Parameter courseId: The ID of the requested course.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error` argument if the request fails;
        otherwise, called with the requested course objectives.
     */
    public func getCourseObjectives(
        courseId: String,
        completion: @escaping (_ error: Error?, _ objectives: [PlayPortalCourseObjective]?) -> Void
    ) {
        let params = [
            "courseId": courseId,
        ]
        
        request(
            url: CourseEndpoints.objectives,
            method: .get,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Retrieves a courses objectives along with a student's performance on the objectives.
     - Parameter courseId: The ID of the requested course.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error` argument if the request fails;
        otherwise, called with the requested course objectives.
     */
    public func getCourseObjectivesPerformances(
        courseId: String,
        completion: @escaping (_ error: Error?, _ objectives: [PlayPortalCourseObjective]?) -> Void
    ) {
        let params = [
            "courseId": courseId,
        ]
        
        request(
            url: CourseEndpoints.performance,
            method: .get,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
}
