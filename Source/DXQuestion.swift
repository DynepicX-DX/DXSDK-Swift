//
//  DXQuestion.swift
//  DXSDK-Swift
//
//  Created by Joshua Paulsen on 7/12/21.
//  Copyright © 2021 Lincoln Fraley. All rights reserved.
//

import Foundation

public struct DXQuestion: Codable {
        
    public let answers: [String]
    public var __t: String
    public var _id: String
    public var course: String
    public var text: String
    public var questionType: String
    public var correctAnswerIndex: Int
    public var createdDate: String
    public var __v: Int
    public var id: String

}
