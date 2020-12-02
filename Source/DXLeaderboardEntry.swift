//
//  DXLeaderboardEntry.swift
//
//  Created by Lincoln Fraley on 10/29/18.
//

import Foundation

//  Represents a playPORTAL user's leaderboard entry
public struct DXLeaderboardEntry: Codable {
  
  public let score: Double
  public let rank: Int
  public let categories: [String]
  public let user: DXProfile
  
  private init() {
    fatalError("`DXLeaderboardEntry` instances should only be initialized by decoding.")
  }
}
