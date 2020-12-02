//
//  File.swift
//  DXSDK-Swift
//
//  Created by Lincoln Fraley on 11/19/19.
//

import Foundation

public struct DXClass: Codable {
    
    public let groupId: String
    public let name: String
    public let joinCode: String
    public var course: DXCourse?
    public let studentId: String
}
