//
//  PlayPortalImage.swift
//
//  Created by Lincoln Fraley on 10/25/18.
//

import Foundation

//  Available routes for playPORTAL image api
fileprivate enum ImageRouter: URLRequestConvertible {
    
    case get(imageId:String)
    
    func asURLRequest() -> URLRequest? {
        switch self {
        case let .get(imageId):
            return Router.get(url: PlayPortalURLs.Image.staticImage + "/" + imageId, params: nil).asURLRequest()
        }
    }
}


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
        requestHandler.request(ImageRouter.get(imageId: imageId)) { error, data in
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
