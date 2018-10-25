//
//  RequestHandler.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 10/23/18.
//

import Foundation
//import Alamofire

////  Responsible for making requests to playPORTAL api services and handling token refresh
//internal class RequestHandler {
//
//    private init() {}
//
////    internal static let shared: SessionManager = {
////
////    }
//}
//
////  Adapt

//  Protocol to be adopted by class responsible for making requests to playPORTAL apis
internal protocol RequestHandler {
    
    //  MARK: - Properties
    
    var accessToken: String? { get set }
    
    var refreshToken: String? { get set }
    
    var isAuthenticated: Bool { get }
    
    
    //  MARK: - Methods
    
    /**
     Make request to playPORTAL api.
     
     - Parameter request: The request being made.
     - Parameter completion: The closure called after the request is made.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter result: The result returned for a successful request.
     
     - Returns: Void
    */
    func request(_ request: URLRequest, _ completion: ((_ error: Error?, _ result: Any?) -> Void)?) -> Void
}
