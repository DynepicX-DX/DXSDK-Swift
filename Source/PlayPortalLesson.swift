//
//  PlayPortalLesson.swift
//  AwaitKit
//
//  Created by Lincoln Fraley on 11/20/19.
//

import Foundation

public struct PlayPortalLesson: Codable {
  
  public let lessonId: String
  public let courseId: String
  public let name: String
  public let description: String
  public let profilePic: String
  public var coverPhoto: String?
  public let media: String
  public var expectedCompletionTime: Int?
  public let instructorGraded: Bool
  public let `public`: Bool
}

public struct PlayPortalLessonProgress<Answers: Codable>: Codable {
  
  public let studentId: String
  public let lessonId: String
  public let pass: Bool
  public var score: Int?
  public var answers: Answers?
  public let started: String
  public var completed: String?
}
