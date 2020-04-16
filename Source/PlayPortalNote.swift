//
//  File.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 4/15/20.
//

import Foundation

public struct PlayPortalNote: Codable {
  
  public let noteId: String
  public let text: String
  public let classId: String?
  public let userId: String?
  public let studentId: String?
  public let courseId: String?
  public let lessonId: String?
}
