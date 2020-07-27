//
//  PlayPortalLessonClient.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 11/20/19.
//

import Foundation

class LessonEndpoints: EndpointsBase {
    
    private static let base = LessonEndpoints.host + "/edu/v1/lesson"
    static let lesson = LessonEndpoints.base
    static let course = LessonEndpoints.base + "/course"
    static let app = LessonEndpoints.base + "/app"
    static let progress = LessonEndpoints.base + "/progress"
    static let start = LessonEndpoints.progress + "/start"
    static let history = LessonEndpoints.progress + "/history"
    static let lock = LessonEndpoints.progress + "/lock"
    static let pause = LessonEndpoints.progress + "/pause"
    static let resume = LessonEndpoints.progress + "/resume"
    static let idle = LessonEndpoints.progress + "/idle"
    static let active = LessonEndpoints.progress + "/active"
    static let objective = LessonEndpoints.progress + "/objective"
}

//  Responsible for making requests to lesson API
public final class PlayPortalLessonClient: PlayPortalHTTPClient {
    
    public static let shared = PlayPortalLessonClient()
    
    
    /**
     Creates a new lesson.
     - Parameter order: Lessons must be completed in a specific order, specified with this
     parameter.
     - Parameter courseId: ID of the course to add the lesson to.
     - Parameter media: A link to the lesson's content.
     - Parameter name: Short name for the course.
     - Parameter description: A long-form description of the course.
     - Parameter profilePic: 64-bit encoded small square JPG to be used as a profile picture
     (or icon) for the lesson.
     - Parameter `public`: Whether or not the lesson is invite only.
     - Parameter coverPhoto: 64-bit encoded wide-resolution JPG to be used as a cover photo
     for the lesson.
     - Parameter completion: The closure invoked when the request finishes. Called with an
     `Error` argument if the request fails; otherwise, called with the newly created
     `PlayPortalLesson`.
     */
    public func createLesson(
        order: Int,
        courseId: String,
        media: String,
        name: String,
        description: String,
        profilePic: String,
        `public`: Bool? = nil,
        coverPhoto: String? = nil,
        _ completion: @escaping (_ error: Error?, _ lesson: PlayPortalLesson?) -> Void)
        -> Void
    {
        let body: [String: Any] = [
            "order": order,
            "courseId": courseId,
            "media": media,
            "name": name,
            "description": description,
            "profilePic": profilePic,
            "public": `public` as Any,
            "coverPhoto": coverPhoto as Any,
        ]
        
        request(
            url: LessonEndpoints.lesson,
            method: .put,
            body: body,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Retrieves a single lesson by ID.
     - Parameter lessonId: The ID of the requested lesson.
     - Parameter completion: The closure invoked when the request finishes. Called with an
     `Error` argument if the request fails; otherwise, called with the requested lesson.
     */
    public func getLesson(
        lessonId: String,
        _ completion: @escaping (_ error: Error?, _ lesson: PlayPortalLesson?) -> Void)
        -> Void
    {
        let params: [String: Any] = [
            "lessonId": lessonId,
        ]
        
        request(
            url: LessonEndpoints.lesson,
            method: .get,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Request all lessons belonging to a course.
     - Parameter courseId: ID of the course.
     - Parameter limit: Page size.
     - Parameter page: Results page to return.
     - Parameter completion: The closure invoked when the request finishes. Called with an
     `Error` argument if the request fails; otherwise, called with the requested lessons.
     */
    public func getLessonsInCourse(
        courseId: String,
        limit: Int? = nil,
        page: Int? = nil,
        _ completion: @escaping (_ error: Error?, _ lessons: [PlayPortalLesson]?) -> Void)
        -> Void
    {
        let params: [String: Any] = [
            "courseId": courseId,
            "limit": limit as Any,
            "page": page as Any,
        ]
        
        let handleSuccess: HandleSuccess<[PlayPortalLesson]> = { response, data in
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let docs = json["docs"] else {
                    throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize PlayPortalLesson array.")
            }
            
            let data = try JSONSerialization.data(withJSONObject: docs, options: [])
            return try self.defaultSuccessHandler(response: response, data: data)
        }
        
        request(
            url: LessonEndpoints.course,
            method: .get,
            queryParameters: params,
            handleSuccess: handleSuccess,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Returns all lessons that belong to the app the user is currently authenticated into,
     filtered by a provided class.
     - Parameter classId: Class to which the requested lessons are assigned.
     - Parameter completion: The closure invoked when the request finishes. Called with an
     `Error` argument if the request fails; otherwise, called with the requested lessons.
     */
    public func getAppLessons(
        classId: String,
        _ completion: @escaping (_ error: Error?, _ lessons: [PlayPortalLesson]?) -> Void)
        -> Void
    {
        let params: [String: Any] = [
            "classId": classId
        ]
        
        request(
            url: LessonEndpoints.app,
            method: .get,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Indicates a student has started taking a lesson, updating the `start` date in the lesson's
     progress. If the user has previously started the lesson but not completed it, this request
     will fail.
     - Parameter classId: Lesson progress is tracked on a class-by-class basis. This parameter
     is the ID of the student's class for which you would like to retrieve progress in this
     lesson for.
     - Parameter lessonId: ID of the lesson.
     - Parameter studentId: Specify which student to return progress for. If not provided, will
     return the progress of the currently authenticated user.
     - Parameter completion: The closure invoked when the request finishes. Called with an
     `Error` argument if the request fails; otherwise, called with an instance of
     `PlayPortalLessonProgress`.
     */
    public func startLesson(
        classId: String,
        lessonId: String,
        studentId: String? = nil,
        _ completion: @escaping (_ error: Error?, _ progress: PlayPortalLessonProgress?) -> Void)
        -> Void
    {
        let body: [String: Any] = [
            "classId": classId,
            "lessonId": lessonId,
            "studentId": studentId as Any,
        ]
        
        request(
            url: LessonEndpoints.start,
            method: .post,
            body: body,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Returns the current (or latest) progress for the specified lesson either for the currently
     authenticated user or a specified user.
     - Parameter classId: Lesson is tracked on a class-by-class basis. This parameter is the
     ID of the student's class for which you would like to retrieve progress in this lesson
     for.
     - Parameter lessonId: ID of the lesson.
     - Parameter studentId: Specify which student to return progress for. If not provided, will
     return the progress of the currently authenticated user.
     - Parameter completion: The closure invoked when the request finishes. Called with an
     `Error` argument if the request fails; otherwise, called with an instance of
     `PlayPortalLessonProgress`.
     */
    public func getStudentsProgress(
        classId: String,
        lessonId: String,
        studentId: String? = nil,
        _ completion: @escaping (_ error: Error?, _ progress: PlayPortalLessonProgress?) -> Void)
        -> Void
    {
        let params: [String: Any] = [
            "classId": classId,
            "lessonId": lessonId,
            "studentId": studentId as Any,
        ]
        
        request(
            url: LessonEndpoints.progress,
            method: .get,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Returns all the attempts for the specified lesson either for the currently authenticated user
     or a specified user.
     - Parameter classId: Lesson progress is tracked on a class-by-class basis. This parameter is
     the ID of the student's class for which you would like to retrieve progress in this lesson for.
     - Parameter lessonId: ID of the lesson.
     - Parameter studentId: Specify which student to return progress for. If not provided, will
     return the progress of the currently authenticated user.
     - Parameter completion: The closure invoked when the request finishes. Called with an
     `Error` argument if the request fails; otherwise, called with the requested progress history.
     */
    public func getStudentsProgressHistory(
        classId: String,
        lessonId: String,
        studentId: String? = nil,
        _ completion: @escaping (_ error: Error?, _ history: [PlayPortalLessonProgress]?) -> Void
    ) -> Void
    {
        let params: [String: Any] = [
            "classId": classId,
            "lessonId": lessonId,
            "studentId": studentId as Any,
        ]
        
        request(
            url: LessonEndpoints.history,
            method: .get,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Updates a student's progress for a lesson in a class with a score, answers, and a pass/fail result.
     
     - Parameter classId: Lesson progress is tracked on a class-by-class basis. This parameter is
     the ID of the student's class for which you would like to retrieve progress in this lesson for.
     - Parameter lessonId: ID of the lesson.
     - Parameter pass: A boolean pass/fail flag.
     - Parameter studentId: Specify which student to return progress for. If not provided, will
     return the progress of the currently authenticated user.
     - Parameter complete: If true, the lesson's `completed` attribute will be set to the current
     date/time, indicating the student has finished the lesson.
     - Parameter answers: An arbitrary data structure representing the student's answers in the lesson.
     This will overwrite previous data structures, so the entire structure must be included with
     every update.
     - Parameter score: A numeric score for the lesson.
     - Parameter startTime: A parseable date to mark the start of the student's session. Suggested
     format is ISO date, eg. 2020-01-07T21:45:35.649Z.
     - Parameter endTime: A parseable date to mark the end of the student's session. Suggested
     format is ISO date, eg. 2020-01-07T21:45:35.649Z.
     - Parameter completion: The closure invoked when the request finishes. Called with an
     `Error` argument if the request fails; otherwise, called with an instance of
     `PlayPortalLessonProgress`.
     */
    public func updateStudentsProgress(
        classId: String,
        lessonId: String,
        pass: Bool,
        studentId: String? = nil,
        complete: Bool? = nil,
        score: Int? = nil,
        startTime: String? = nil,
        endTime: String? = nil,
        _ completion: @escaping (_ error: Error?, _ progress: PlayPortalLessonProgress?) -> Void
    ) -> Void
    {
        let body: [String: Any?] = [
            "classId": classId,
            "lessonId": lessonId,
            "pass": pass,
            "studentId": studentId,
            "complete": complete,
            "score": score,
            "startTime": startTime,
            "endTime": endTime
        ]
        
        request(
            url: LessonEndpoints.progress,
            method: .post,
            body: body,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Checks whether or not the specified lesson is currently locked or unlocked.
     - Parameter classId: Lesson progress is tracked on a class-by-class basis. This parameter is the ID of the student's
        class for which you would like to retrieve progress in this lesson for.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error` argument if the request fails;
        otherwise, called with the lessons for that student.
     */
    public func getLesonsLockStatus(
        classId: String,
        _ completion: @escaping (_ error: Error?, _ lessons: [PlayPortalLesson]?) -> Void
    ) {
        let params = [
            "classId": classId,
        ]
        
        request(
            url: LessonEndpoints.lock,
            method: .get,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Indicates that a student has paused progress on a lesson. The "progressIntervals" attribute will be updated with the
        previous start time and an end time of the current time.
     - Parameter lessonId: ID of the lesson.
     - Parameter classId: Lesson progress is tracked on a class-by-class basis. This parameter is the ID of the student's
        class for which you would like to update the student's progress.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error` argument if the request fails;
        otherwise, called with the paused lesson.
     */
    public func pauseLesson(
        lessonId: String,
        classId: String,
        _ completion: @escaping (_ error: Error?, _ lessonProgress: PlayPortalLessonProgress?) -> Void
    ) {
        let params = [
            "classId": classId,
            "lessonId": lessonId,
        ]
        
        request(
            url: LessonEndpoints.pause,
            method: .post,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Indicates that a student has resumed progress on a paused lesson.
     - Parameter lessonId: ID of the lesson.
     - Parameter classId: Lesson progress is tracked on a class-by-class basis. This parameter is the ID of the student's
        class for which you would like to update the student's progress.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error` argument if the request fails;
        otherwise, called with the resumed argument.
     */
    public func resumeLesson(
        lessonId: String,
        classId: String,
        _ completion: @escaping (_ error: Error?, _ lessonProgress: PlayPortalLessonProgress?) -> Void
    ) {
        let params = [
            "classId": classId,
            "lessonId": lessonId,
        ]
        
        request(
            url: LessonEndpoints.resume,
            method: .post,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Indicates that the student's progress is temporarily paused. The "idleIntervals" attribute will be updated with the
        previous start time and an end time of the current time.
     - Parameter lessonId: ID of the lesson.
     - Parameter classId: Lesson progress is tracked on a class-by-class basis. This parameter is the ID of the student's
        class for which you would like to update the student's progress.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error` argument if the request fails;
        otherwise, called with the lesson progress marked as idle.
     */
    public func startIdleTimeForLesson(
        lessonId: String,
        classId: String,
        _ completion: @escaping (_ error: Error?, _ lessonProgress: PlayPortalLessonProgress?) -> Void
    ) {
        let params = [
            "classId": classId,
            "lessonId": lessonId,
        ]
        
        request(
            url: LessonEndpoints.idle,
            method: .post,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Indicates that a student has ended idle time.
     - Parameter lessonId: ID of the lesson.
     - Parameter classId: Lesson progress is tracked on a class-by-class basis. This parameter is the ID of the student's
     class for which you would like to update the student's progress.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error` argument if the request fails;
     otherwise, called with the lesson progress marked as active.
     */
    public func endIdleTimeForLesson(
        lessonId: String,
        classId: String,
        _ completion: @escaping (_ error: Error?, _ lessonProgress: PlayPortalLessonProgress?) -> Void
    ) {
        let params = [
            "classId": classId,
            "lessonId": lessonId,
        ]
        
        request(
            url: LessonEndpoints.active,
            method: .post,
            queryParameters: params,
            completionWithDecodableResult: completion
        )
    }
    
    /**
     Updates a student's objective score for a lesson, if the objective score is different than the student's overall lesson
     score.
     - Parameter lessonId: ID of the lesson.
     - Parameter classId: Lesson progress is tracked on a class-by-class basis. This parameter is the ID of the student's
     class for which you would like to update the student's progress.
     - Parameter objectiveId: The objective's ID.
     - Parameter score: A numeric score from 0-100.
     - Parameter completion: Closure invoked when the request finishes. Called with an `Error` argument if the request fails.
     */
    public func updateStudentsObjectiveScore(
        lessonId: String,
        classId: String,
        objectiveId: String,
        score: Int,
        _ completion: @escaping (_ error: Error?) -> Void
    ) {
        let params = [
            "classId": classId,
            "lessonId": lessonId,
        ]
        
        let body: [String: Any] = [
            "objectiveId": objectiveId,
            "score": score,
        ]
        
        request(
            url: LessonEndpoints.objective,
            method: .post,
            queryParameters: params,
            body: body,
            completionWithNoResult: completion
        )
    }
}
