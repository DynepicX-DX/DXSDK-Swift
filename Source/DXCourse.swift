//
//  DXCourse.swift
//  KeychainSwift
//
//  Created by Lincoln Fraley on 11/19/19.
//

import Foundation

public struct DXCourse: Codable {
  
  public let courseId: String
  public let name: String
  public var description: String?
  public var profilePic: String?
  public var coverPhoto: String?
}
