//
//  RequestHandler.swift
//
//  Created by Lincoln Fraley on 12/4/18.
//

import Foundation
import Alamofire


protocol HTTPRequester {
    
    func request(
        _ request: URLRequest,
        _ completion: ((_ error: Error?, _ response: HTTPURLResponse?, _ data: Data?) -> Void)?)
        -> Void
}

fileprivate final class AlamofireHTTPRequester {
    
    static let shared = AlamofireHTTPRequester()
    fileprivate static let sessionManager: SessionManager = {
        var sessionManager = SessionManager(configuration: .default)
        sessionManager.retrier = RequestHandler.shared
        return sessionManager
    }()
    
    private init() {}
}

extension AlamofireHTTPRequester: HTTPRequester {
    
    func request(
        _ request: URLRequest,
        _ completion: ((Error?, HTTPURLResponse?, Data?) -> Void)?)
        -> Void
    {
        AlamofireHTTPRequester.sessionManager
            .request(request)
            .validate(statusCode: 200..<300)
            .response { completion?($0.error, $0.response, $0.data) }
    }
}

final class RequestHandler {
    
    static let shared = RequestHandler()
    private let requester: HTTPRequester = AlamofireHTTPRequester.shared
    private let lock = NSLock()
    private var requestsToRetry = [RequestRetryCompletion]()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.dynepic.playPORTAL.RequestManagerQueue", attributes: .concurrent)
    private var isRefreshing = Synchronized(value: false)
    private var accessToken: String? {
        get { return queue.sync { globalStorageHandler.get("PPSDK-accessToken") }}
        set(accessToken) {
            if let accessToken = accessToken {
                queue.async(flags: .barrier) { globalStorageHandler.set(accessToken, atKey: "PPSDK-accessToken") }
            }
        }
    }
    private var refreshToken: String? {
        get { return queue.sync { globalStorageHandler.get("PPSDK-refreshToken") }}
        set(refreshToken) {
            if let refreshToken = refreshToken {
                queue.async(flags: .barrier) { globalStorageHandler.set(refreshToken, atKey: "PPSDK-refreshToken") }
            }
        }
    }
    var isAuthenticated: Bool {
        get { return accessToken != nil && refreshToken != nil }
    }
    
    private init() { }
    
    deinit {
        EventHandler.shared.unsubscribe(self)
    }
    
    private func _request(
        _ request: PPSDK_Swift.URLRequestConvertible,
        at keyPath: String? = nil,
        _ completion: ((_ error: Error?, _ result: Any?) -> Void)?)
        -> Void
    {
        var request = request.asURLRequest()
        if let accessToken = accessToken {
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        requester.request(request) { error, response, data in
            if let error = response.flatMap({ PlayPortalError.API.createError(from: $0) }) {
                completion?(error, nil)
            } else if error != nil {
                completion?(error, nil)
            } else {
                var result = data as Any?
                if let keys = keyPath?.split(separator: ".").map(String.init),
                    let json = data?.asJSON,
                    let nestedValue = json.valueAtNestedKey(keys) {
                    result = try? JSONSerialization.data(withJSONObject: nestedValue, options: [])
                }
                completion?(nil, result)
            }
        }
    }
    
    func request(
        _ request: PPSDK_Swift.URLRequestConvertible,
        at keyPath: String? = nil,
        _ completion: ((_ error: Error?, _ result: Any?) -> Void)?)
        -> Void
    {
        _request(request, at: keyPath, completion)
    }
    
    func request(
        _ request: PPSDK_Swift.URLRequestConvertible,
        at keyPath: String? = nil,
        _ completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        _request(request, at: keyPath) { error, _ in
            completion?(error)
        }
    }
    
    func request<Result: Codable>(
        _ request: PPSDK_Swift.URLRequestConvertible,
        at keyPath: String? = nil,
        _ completion: ((_ error: Error?, _ result: Result?) -> Void)?)
        -> Void
    {
        _request(request, at: keyPath) { error, result in
            if let error = error {
                completion?(error, nil)
            } else {
                let result: Result? = {
                    switch Result.self {
                    case is Data.Type:
                        return result as? Result
                    default:
                        return (result as? Data).flatMap { try? self.decoder.decode(Result.self, from: $0) }
                    }
                }()
                let err = result == nil ? PlayPortalError.API.unableToDeserializeResponse : nil
                completion?(err, result)
            }
        }
    }
    
    //  TODO: handle logout clean up
    func logout(_ completion: @escaping (Error?) -> Void) -> Void {
        request(AuthRouter.logout(refreshToken: refreshToken)) { error in
            completion(error)
        }
    }
}

extension RequestHandler: EventSubscriber {
    
    func on(event: Event) {
        switch event {
        case let .authenticated(accessToken, refreshToken):
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        case .firstRun:
            globalStorageHandler.delete("PPSDK-accessToken")
            globalStorageHandler.delete("PPSDK-refreshToken")
        case .loggedOut:
            globalStorageHandler.delete("PPSDK-accessToken")
            globalStorageHandler.delete("PPSDK-refreshToken")
        }
    }
}

extension RequestHandler: RequestRetrier {
    
    func should(
        _ manager: SessionManager,
        retry request: Request,
        with error: Error,
        completion: @escaping RequestRetryCompletion)
    {
        lock.lock(); defer { lock.unlock() }
        requestsToRetry.append(completion)
        
        if let response = request.task?.response as? HTTPURLResponse,
            PlayPortalError.API.ErrorCode.errorCode(for: response) == .tokenRefreshRequired {
            if !isRefreshing.value {
                isRefreshing.value = true
                //  TODO: handle when tokens are nil
                PlayPortalAuth.shared.refresh(accessToken: accessToken!, refreshToken: refreshToken!) { error, accessToken, refreshToken in
                    self.lock.lock(); defer { self.lock.unlock() }
                    self.accessToken = accessToken
                    self.refreshToken = refreshToken
                    self.requestsToRetry.forEach { $0(error == nil, 0.0) }
                    self.requestsToRetry.removeAll()
                    self.isRefreshing.value = false
                    if error != nil {
                        EventHandler.shared.publish(.loggedOut(error: error))
                    }
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
}
