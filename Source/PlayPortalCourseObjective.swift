//
//  PlayPortalCourseObjective.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 7/27/20.
//

import Foundation

public class PlayPortalCourseObjective: Codable {
    
    public let objectiveId: String
    public let name: String
    public let lessonIds: [String]
    public let skill: Int?
    public let skillDescription: SkillDescription?
    public let score: Int?
    public let lessonScores: [LessonScore]
    
    public enum SkillDescription: String, Codable {
        
        case basic = "Basic"
        case advanced = "Advanced"
        case expert = "Expert"
    }

    public class LessonScore: Codable {
        
        public let lessonId: String
        public let score: Int
        public let scoreType: String
    }
}
