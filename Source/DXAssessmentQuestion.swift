//
//  DXAssessmentQuestion.swift
//  DXSDK-Swift
//
//  Created by Lincoln Fraley on 1/8/20.
//

import Foundation

public struct DXAssessmentQuestion: Codable {
  
  public let answers: [String]
  public let questionType: String
  public let question: String
  public let correctAnswerIndex: Int
}
