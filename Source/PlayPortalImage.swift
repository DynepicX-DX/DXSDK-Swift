//
//  PlayPortalImage.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 10/25/18.
//

import Foundation

//  Responsible for making requests to playPORTAL image api
public final class PlayPortalImage {
    
    //  MARK: - Properties
    
    //  Singleton instance
    public static let shared = PlayPortalImage()
    
    //  Handler for making api requests
    private var requestHandler: RequestHandler = globalRequestHandler
    
    
    //  MARK: - Initializers
    
    //  Private init to force use of singleton
    private init() {}
    
    
    //  MARK: - Methods
    
    /**
     Make request for playPORTAL image by its id
     
     - Parameter forImageId: Id of the image being requested
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter data: The data representing the image returned for a successful request.
     
     - Returns: Void
     */
    public func getImage(forImageId imageId: String, _ completion: @escaping (_ error: Error?, _ data: Data?) -> Void) -> Void {
        
        //  Create url request
        let host = PlayPortalURLs.getHost(forEnvironment: PlayPortalAuth.shared.environment)
        let path = PlayPortalURLs.Image.staticImage
        
        guard let url = URL(string: host + path + "/" + imageId) else {
            completion(PlayPortalError.API.failedToMakeRequest(message: "Unable to construct url for request."), nil)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        //  Make request
        requestHandler.requestData(urlRequest) { error, data in
            guard error == nil
                , let data = data
                else {
                    completion(error, nil)
                    return
            }
            completion(nil, data)
        }
    }
}
