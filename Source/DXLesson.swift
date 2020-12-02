//
//  DXLesson.swift
//  AwaitKit
//
//  Created by Lincoln Fraley on 11/20/19.
//

import Foundation

public struct DXLesson: Codable {
    
    public let lessonId: String
    public var courseId: String?
    public let name: String
    public var description: String?
    public var profilePic: String?
    public var coverPhoto: String?
    public var media: String?
    public let childLessons: [DXLesson]
    public var expectedCompletionTime: Int?
    public var instructorGraded: Bool?
    public var `public`: Bool?
    public let locked: Bool
}

public struct DXLessonProgress: Codable {
    
    public let studentId: String
    public let lessonId: String
    public let pass: Bool
    public var score: Int?
    public let answers: [DXAssessmentAnswer]
    public var started: String?
    public var completed: String?
    public let progressIntervals: [Interval]
    public let idleIntervals: [Interval]
    
    public class Interval: Codable {
        public let start: String
        public let end: String?
    }
}

public struct DXAssessmentAnswer: Codable {
    
    public let question: String
    public var answer: String?
    public var correct: Bool?
}
