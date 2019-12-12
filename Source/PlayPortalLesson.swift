//
//  PlayPortalLesson.swift
//  AwaitKit
//
//  Created by Lincoln Fraley on 11/20/19.
//

import Foundation

public struct PlayPortalLesson: Codable {
  
  public let lessonId: String
  public var courseId: String?
  public let name: String
  public var description: String?
  public var profilePic: String?
  public var coverPhoto: String?
  public var media: String?
  public var expectedCompletionTime: Int?
  public var instructorGraded: Bool?
  public var `public`: Bool?
}

public struct PlayPortalLessonProgress<Answers: Codable>: Codable {
  
  public let studentId: String
  public let lessonId: String
  public let pass: Bool
  public var score: Int?
  public var answers: Answers?
  public var started: String?
  public var completed: String?
}
