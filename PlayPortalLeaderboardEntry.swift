//
//  PlayPortalLeaderboardEntry.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 10/29/18.
//

import Foundation

//  Class representing a playPORTAL user's leaderboard entry
public struct PlayPortalLeaderboardEntry {
    
    //  MARK: - Properties
    public let score: Double
    public let rank: Int
    public let categories: [String]
    public let user: PlayPortalProfile
    
    
    //  MARK: - Initializers
    
    /**
     Create leaderboard entry from JSON.
     
     - Parameter from: The JSON object representing the leaderboard entry.
     
     - Throws: If any of the properties are unable to be deserialized from the JSON.
     
     - Returns: `PlayPortalLeaderboardEntry` instance.
    */
    internal init(from json: [String: Any]) throws {
        
        //  Deserialized properties
        guard let score = json["score"] as? Double else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'score' from JSON.")
        }
        guard let rank = json["rank"] as? Int else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'rank' from JSON.")
        }
        guard let categories = json["categories"] as? [String] else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'categories' from JSON.")
        }
        guard let user = json["user"] as? [String: Any] else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'user' from JSON.")
        }
        
        self.score = score
        self.rank = rank
        self.categories = categories
        self.user = try PlayPortalProfile(from: user)
    }
}
