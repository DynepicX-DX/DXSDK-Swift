//
//  AlamofireRequestHandler.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 10/25/18.
//

import Foundation
import Alamofire

//  Class implementing `RequestHandler` and using Alamofire internally
internal class AlamofireRequestHandler {
    
    //  MARK: - Properties
    
    //  Internal properties for tokens
    private var _accessToken: String?
    
    private var _refreshToken: String?
    
    //  Singleton instance
    internal static let shared = AlamofireRequestHandler()
    
    //  `SessionManager` instance
    fileprivate static let sessionManager: SessionManager = {
        var sessionManager = SessionManager(configuration: .default)
        sessionManager.retrier = TokenRetrier()
        sessionManager.adapter = TokenAdapter()
        return sessionManager
    }()
    
    
    //  MARK: - Initializers
    
    //  Private init to force use of singleton
    private init() {}
}

extension AlamofireRequestHandler: RequestHandler {
    
    //  MARK: - Properties
    
    //  playPORTAL SSO tokens
    fileprivate (set) var accessToken: String? {
        get {
            return globalStorageManager.get("accessToken")
        }
        set {
            if let accessToken = newValue {
                globalStorageManager.set(accessToken, atKey: "accessToken")
            }
        }
    }
    
    fileprivate (set) var refreshToken: String? {
        get {
            return globalStorageManager.get("refreshToken")
        }
        set {
            if let refreshToken = newValue {
                globalStorageManager.set(refreshToken, atKey: "refreshToken")
            }
        }
    }
    
    //  User is authenticated if both `accessToken` and `refreshToken` aren't nil
    var isAuthenticated: Bool {
        return globalStorageManager.get("accessToken") != nil && globalStorageManager.get("refreshToken") != nil
    }
    
    
    //  MARK: - Methods
    
    /**
     Set SSO tokens.
    */
    @discardableResult
    func set(accessToken: String, andRefreshToken refreshToken: String) -> Bool {
        return globalStorageManager.set(accessToken, atKey: "accessToken")
            && globalStorageManager.set(refreshToken, atKey: "refreshToken")
    }
    
    /**
     Clear SSO tokens.
    */
    @discardableResult
    func clearTokens() -> Bool {
        return globalStorageManager.delete("accessToken") && globalStorageManager.delete("refreshToken")
    }
    
    /**
     Make request for JSON using internal `sessionManager` instance
     */
    func requestJSON(_ request: URLRequest, _ completion: ((Error?, [String: Any]?) -> Void)?) {
        AlamofireRequestHandler.sessionManager
            .request(request)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case let .failure(error):
                    guard let urlResponse = response.response else {
                        completion?(error, nil)
                        return
                    }
                    let error = PlayPortalError.API.createError(from: urlResponse)
                    completion?(error, nil)
                case let .success(value):
                    guard let value = value as? [String: Any] else {
                        completion?(PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize JSON from result."), nil)
                        return
                    }
                    completion?(nil, value)
                }
        }
    }
    
    /**
     Make request for a JSON array using internal `sessionManager` instance
     */
    func requestJSONArray(_ request: URLRequest, _ completion: ((Error?, [[String: Any]]?) -> Void)?) {
        AlamofireRequestHandler.sessionManager
            .request(request)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case let .failure(error):
                    guard let urlResponse = response.response else {
                        completion?(error, nil)
                        return
                    }
                    let error = PlayPortalError.API.createError(from: urlResponse)
                    completion?(error, nil)
                case let .success(value):
                    guard let value = value as? [[String: Any]] else {
                        completion?(PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize JSON from result."), nil)
                        return
                    }
                    completion?(nil, value)
                }
        }
    }
    
    /**
     Make request for data using internal `sessionManager` instance
     */
    func requestData(_ request: URLRequest, _ completion: ((Error?, Data?) -> Void)?) {
        AlamofireRequestHandler.sessionManager
            .request(request)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case let .failure(error):
                    guard let urlResponse = response.response else {
                        completion?(error, nil)
                        return
                    }
                    let error = PlayPortalError.API.createError(from: urlResponse)
                    completion?(error, nil)
                case let .success(value):
                    completion?(nil, value)
                }
        }
    }
}


//  Class implementing Alamofire `RequestAdapter`
fileprivate class TokenAdapter {
    
}

extension TokenAdapter: RequestAdapter {
    
    //  Add access token to header for requests to playPORTAL apis
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        if let accessToken = AlamofireRequestHandler.shared.accessToken {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}


//  Class implementing Alamofire `RequestRetrier`
fileprivate class TokenRetrier {
    
    //  MARK: - Properties
    
    //  Lock when refreshing
    fileprivate let lock = NSLock()
    
    //  Flag to indicate if a refresh is currently underway
    fileprivate var isRefreshing = false
    
    //  Requests to retry once refresh has finished
    fileprivate var requestsToRetry = [RequestRetryCompletion]()
}

extension TokenRetrier: RequestRetrier {
    
    //  Requests should be retried when there is a refresh error
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        //  Lock so refresh only occurs once
        lock.lock(); defer { lock.unlock() }
        
        requestsToRetry.append(completion)
        
        //  Refresh should only occur on refresh required error
        if let response = request.task?.response as? HTTPURLResponse
            , PlayPortalError.API.ErrorCode.errorCode(for: response) == .tokenRefreshRequired {
            if !isRefreshing {
                isRefreshing = true
                PlayPortalAuth.shared.refresh { [weak self] error, accessToken, refreshToken in
                    guard let strongSelf = self
                        , error == nil
                        , let accessToken = accessToken
                        , let refreshToken = refreshToken
                        else {
                            completion(false, 0.0)
                            return
                    }
                    strongSelf.lock.lock(); defer { strongSelf.lock.unlock() }
                    AlamofireRequestHandler.shared.accessToken = accessToken
                    AlamofireRequestHandler.shared.refreshToken = refreshToken
                    strongSelf.requestsToRetry.forEach { $0(true, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                    strongSelf.isRefreshing = false
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
}
