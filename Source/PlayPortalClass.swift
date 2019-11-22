//
//  File.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 11/19/19.
//

import Foundation

public struct PlayPortalClass: Codable {
  
  public let groupId: String
  public let name: String
  public let joinCode: String
  public var course: PlayPortalCourse?
}
