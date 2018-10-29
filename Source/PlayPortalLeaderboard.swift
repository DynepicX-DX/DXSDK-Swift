//
//  PlayPortalLeaderboard.swift
//  Nimble
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation

//  Responsible for making requests to playPORTAL leaderboard api
public final class PlayPortalLeaderboard {
    
    //  MARK: - Properties
    
    //  Singleton instance
    public static let shared = PlayPortalLeaderboard()
    
    //  Handler for making api requests
    private var requestHandler: RequestHandler = globalRequestHandler
    
    
    //  MARK: - Initializers
    
    //  Private init to force use of singleton
    private init() {}
    
    
    //  MARK: - Methods
    
    static func getLeaderboard() {}
    
    static func updateLeaderboard() {}
}
