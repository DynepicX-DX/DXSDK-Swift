//
//  RequestManager.swift
//  Alamofire
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
        sessionManager.retrier = RequestManager.shared
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

final class RequestManager {
    
    static let shared = RequestManager()
    private let requester: HTTPRequester = AlamofireHTTPRequester.shared
    private let lock = NSLock()
    private var requestsToRetry = [RequestRetryCompletion]()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.dynepic.playPORTAL.RequestManagerQueue", attributes: .concurrent)
    private var isRefreshing = Synchronized(value: false)
    private var accessToken: String? {
        get { return queue.sync { globalStorageManager.get("PPSDK-accessToken") }}
        set(accessToken) {
            if let accessToken = accessToken {
                queue.async(flags: .barrier) { globalStorageManager.set(accessToken, atKey: "PPSDK-accessToken") }
            }
        }
    }
    private var refreshToken: String? {
        get { return queue.sync { globalStorageManager.get("PPSDK-refreshToken") }}
        set(refreshToken) {
            if let refreshToken = refreshToken {
                queue.async(flags: .barrier) { globalStorageManager.set(refreshToken, atKey: "PPSDK-refreshToken") }
            }
        }
    }
    var isAuthenticated: Bool {
        get { return accessToken != nil && refreshToken != nil }
    }
    
    private init() {
        EventHandler.shared.subscribe(self)
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
        requester.request(request) { error, response, result in
            if let error = response.flatMap({ PlayPortalError.API.createError(from: $0) }) {
                completion?(error, nil)
            } else if error != nil {
                completion?(error, nil)
            } else {
                let err = result == nil ? PlayPortalError.API.unableToDeserializeResponse : nil
                completion?(err, result)
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
            //  TODO: this needs to be cleaned up
            var data = result as? Data
            if let keys = keyPath?.split(separator: ".").map({ String($0) }), let json = data?.asJSON {
                //  TODO: create an extension for getting nested values 
                let nestedValue = keys.dropLast()
                    .reduce(json) { current, next in current?[next] as? [String: Any] }?[keys.last ?? ""]
                data = nestedValue.flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) } ?? data
            }
            let result = data?.asJSON == nil
                ? data as? Result
                : data.flatMap { try? self.decoder.decode(Result.self, from: $0) }
            let err = result == nil ? PlayPortalError.API.unableToDeserializeResponse : nil
            completion?(err, result)
        }
    }
    
    //  TODO: handle logout clean up
    func logout(_ completion: @escaping (Error?) -> Void) -> Void {
        request(AuthRouter.logout(refreshToken: refreshToken)) { (error, _: Data?) in
            completion(error)
        }
    }
}

extension RequestManager: EventSubscriber {
    
    func on(event: Event) {
        switch event {
        case let .authenticated(accessToken, refreshToken):
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        case .firstRun:
            globalStorageManager.delete("accessToken")
            globalStorageManager.delete("refreshToken")
        case .loggedOut:
            globalStorageManager.delete("accessToken")
            globalStorageManager.delete("refreshToken")
        }
    }
}

extension RequestManager: RequestRetrier {
    
    func should(
        _ manager: SessionManager,
        retry request: Request,
        with error: Error,
        completion: @escaping RequestRetryCompletion)
    {
        lock.lock(); defer { lock.unlock() }
        requestsToRetry.append(completion)
        
        if let response = request.task?.response as? HTTPURLResponse
            , PlayPortalError.API.ErrorCode.errorCode(for: response) == .tokenRefreshRequired {
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
