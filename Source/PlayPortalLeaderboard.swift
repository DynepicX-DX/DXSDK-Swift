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
    
    /**
     Request leaderboard entries.
     
     - Parameter page: Supports pagination: at what page to get leaderboards from; defaults to nil (returns first page).
     - Parameter limit: How many entries to get; defaults to nil (returns 10 entries).
     - Parameter forCategories: What entries to return based on their tags.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter leaderboardEntries: The leaderboard entries returned for a successful request.
     
     - Returns: Void
    */
    public func getLeaderboard(
        _ page: Int? = nil,
        _ limit: Int? = nil,
        forCategories categories: [String],
        _ completion: @escaping (_ error: Error?, _ leaderboardEntries: [PlayPortalLeaderboardEntry]?) -> Void)
        -> Void
    {
        
        //  Create url request
        guard let urlRequest = URLRequest.from(
            method: "GET",
            andURL: PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + PlayPortalURLs.Leaderboard.leaderboard,
            andQueryParams: [
                "categories": categories.joined(separator: ","),
                "page": page == nil ? nil : String(page!),
                "limit": limit == nil ? nil : String(limit!)
            ]) else {
                completion(PlayPortalError.API.failedToMakeRequest(message: "Failed to construct 'URLRequest'."), nil)
                return
        }
        
        //  Make request
        requestHandler.request(urlRequest) { error, data in
            guard error == nil
                , let json = data?.toJSON
                , let docs = json["docs"] as? [[String: Any]]
                else {
                    completion(error, nil)
                    return
            }
            let leaderboardEntries = docs.compactMap { try? PlayPortalLeaderboardEntry(from: $0) }
            completion(nil, leaderboardEntries)
        }
    }
    
    /**
     Add score to the global leaderboard.
     
     - Parameter score: The score being added.
     - Parameter forCategories: List of categories to tag the score with.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter leaderboardEntry: The leaderboard entry returned for a successful request.
     
     - Returns: Void
    */
    public func updateLeaderboard(
        _ score: Double,
        forCategories categories: [String],
        _ completion: ((_ error: Error?, _ leaderboardEntry: PlayPortalLeaderboardEntry?) -> Void)?)
        -> Void
    {
        
        //  Create url request
        guard let urlRequest = URLRequest.from(
            method: "POST",
            andURL: PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + PlayPortalURLs.Leaderboard.leaderboard,
            andBody: [
                "score": score,
                "categories": categories
            ]) else {
                completion?(PlayPortalError.API.failedToMakeRequest(message: "Failed to construct 'URLRequest'."), nil)
                return
        }
        
        //  Make request
        requestHandler.request(urlRequest) { error, data in
            guard error == nil
                , let json = data?.toJSON
                else {
                    completion?(error, nil)
                    return
            }
            do {
                let leaderboardEntry = try PlayPortalLeaderboardEntry(from: json)
                completion?(nil, leaderboardEntry)
            } catch {
                completion?(error, nil)
            }
        }
    }
}
