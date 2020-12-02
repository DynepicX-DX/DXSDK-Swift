//
//  DXStudentComment.swift
//  DXSDK-Swift
//
//  Created by Lincoln Fraley on 11/20/19.
//

import Foundation

public struct DXStudentComment: Codable {
  
  public let commentId: String
  public let student: DXProfile
  public let author: DXProfile
  public var course: String?
  public var lesson: String?
  public var `class`: String?
  public let text: String
}
