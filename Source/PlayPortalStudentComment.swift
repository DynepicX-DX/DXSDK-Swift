//
//  PlayPortalStudentComment.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 11/20/19.
//

import Foundation

public struct PlayPortalStudentComment: Codable {
  
  public let commentId: String
  public let student: PlayPortalProfile
  public let author: PlayPortalProfile
  public var course: String?
  public var lesson: String?
  public var `class`: String?
  public let text: String
}
