//
//  PlayPortalNotifications.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 12/19/18.
//

import Foundation
import UserNotifications

//  Available routes for playPORTAL notifications api
fileprivate enum NotificationRouter: URLRequestConvertible {
    
    case create(text: String, receiver: String, persist: Bool)
    case register(refreshToken: String, deviceToken: String)
    case read(since: Int?, page: Int?, limit: Int?, acknowledged: Bool?)
    case acknowledge(notificationId: String)
    
    func asURLRequest() -> URLRequest {
        switch self {
        case let .create(text, receiver, persist):
            let body: [String: Any] = [
                "text": text,
                "receiver": receiver,
                "persist": persist
            ]
            return Router.put(url: URLs.Notification.create, body: body, params: nil).asURLRequest()
        case let .register(refreshToken, deviceToken):
            let body = [
                "refreshToken": refreshToken,
                "deviceToken": deviceToken
            ]
            return Router.put(url: URLs.Notification.register, body: body, params: nil).asURLRequest()
        case let .read(since, page, limit, acknowledged):
            let params: [String: Any?] = [
                "since": since,
                "page": page,
                "limit": limit,
                "acknowledged": acknowledged
            ]
            return Router.get(url: URLs.Notification.read, params: params).asURLRequest()
        case let .acknowledge(notificationId):
            let body = [
                "notificationId": notificationId
            ]
            return Router.post(url: URLs.Notification.acknowledge, body: body, params: nil).asURLRequest()
        }
    }
}

//  Responsible for registering for notifications and making requests to playPORTAL notifications api
public class PlayPortalNotifications {
    
    public static let shared = PlayPortalNotifications()
    
    private init() {}
    
    /**
     Register for remote notifications.
     - Parameter options: The authorization options you want your app to have.
     - Parameter deviceToken: If your app already uses remote notifications, you can send in your existing device token to register with the playPORTAL notifications api.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request. This error can result from an error during the `UNUserNotificationCenter` authorization process
        or be an error returned from the playPORTAL notifications api.
    */
    public func register(
        options: [UNAuthorizationOptions] = [.badge, .sound, .alert],
        deviceToken: Data? = nil,
        _ completion: ((_ error: Error?) -> Void)?)
    {
        if let deviceToken = deviceToken?.toHex {
            register(deviceToken: deviceToken) { error in
                completion?(error)
            }
        } else {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { granted, error in
                guard granted else {
                    completion?(nil)
                    return
                }
                guard error == nil else {
                    completion?(error)
                    return
                }
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else {
                        completion?(nil)
                        return
                    }
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
    /**
     Handles device token registration.
     - Parameter withDeviceToken: The device token returned by iOS.
     - Parameter completion: The closure invoked when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
    */
    public func didRegisterForRemoteNotifications(
        withDeviceToken deviceToken: Data,
        _ completion: ((_ error: Error?) -> Void)?)
        -> Void
    {
        register(deviceToken: deviceToken.toHex) { error in
            completion?(error)
        }
    }
    
    //  Request api to add device token to current session.
    private func register(
        deviceToken: String,
        _ completion: @escaping (_ error: Error?) -> Void)
        -> Void
    {
        assert(RequestHandler.shared.refreshToken != nil, "User must be logged in before registering for push notifications.")
        let request = NotificationRouter.register(refreshToken: RequestHandler.shared.refreshToken ?? "", deviceToken: deviceToken)
        RequestHandler.shared.request(request, completion)
    }
}
