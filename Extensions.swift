//
//  Extensions.swift
//
//  Created by Lincoln Fraley on 11/8/18.
//

import Foundation

//  MARK: - Data
extension Data {
    
    /**
     Convert data to JSON.
     
     - Returns: JSON if able to successfully serialize
     */
    var toJSON: [String: Any]? {
        get {
            guard let json = try? JSONSerialization.jsonObject(with: self, options: []) else { return nil }
            return json as? [String: Any]
        }
    }
    
    /**
     Convert data to JSON array.
     
     - Returns: JSON array if able to successfully serialize
     */
    var toJSONArray: [[String: Any]]? {
        get {
            guard let json = try? JSONSerialization.jsonObject(with: self, options: [])
                , let array = json as? [Any]
                else {
                    return nil
            }
            return array.compactMap { $0 as? [String: Any] }
        }
    }
    
    /**
     Convert data to type of `Decodable`.
     
     - Parameter type: The type of Decodable that is being decoded to.
     
     - Returns: The instance of Decodable if decoded successfully, nil otherwise.
     */
    func asDecodable<D: Decodable>(type: D.Type) -> D? {
        return try? JSONDecoder().decode(type, from: self)
    }
}


//  MARK: - Dictionary
internal extension Dictionary where Key == String, Value == Any {
    
    func asDecodable<D: Decodable>(type: D.Type) -> D? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}


//  MARK: - Encodable
internal extension Encodable {
    
    var asDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}


//  MARK: - URLRequest
extension URLRequest {
    
    /**
     Factory method for creating `URLRequest`.
     
     - Parameter method: Request method.
     - Parameter andURL: URL of request.
     - Parameter andBody: Request body.
     - Parameter andQueryParams: URL query parameters.
     - Parameter andHeaders: Request headers.
     
     - Returns: `URLRequest` if it's able to be created successfully.
     */
    static func from(
        method: String,
        andURL urlString: String,
        andBody body: [String: Any?]? = nil,
        andQueryParams queryParams: [String: String?]? = nil,
        andHeaders headers: [String: String]? = nil)
        -> URLRequest?
    {
        var url = URL(string: urlString)
        
        //  Add query parameters
        if let queryParams = queryParams {
            var params = [String: String]()
            for (key, value) in queryParams where value != nil {
                params[key] = value!
            }
            url = url?.with(queryParams: params)
        }
        
        //  Create url request with url
        guard url != nil else { return nil }
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = method
        
        //  Add body
        if var body = body {
            for (key, value) in body where value != nil {
                body[key] = value!
            }
            do {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
            } catch {
                return nil
            }
        }
        
        //  Add headers
        if let headers = headers {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return urlRequest
    }
}


//  MARK: - URL
extension URL {
    
    /**
     Create a URL with a dictionary of query parameters.
     
     - Parameter queryParams: Dictionary from which to create query parameters.
     
     - Returns: URL with query parameters if successful, nil otherwise.
     */
    func with(queryParams params: [String: String]) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        var queryItems = [URLQueryItem]()
        for (name, value) in params {
            queryItems.append(URLQueryItem(name: name, value: value))
        }
        components.queryItems = queryItems
        return try? components.asURL()
    }
    
    /**
     Get a query parameter by name.
     
     - Parameter for: Name of parameter to return.
     
     - Returns: Parameter if successful, nil otherwise.
     */
    func getParameter(for name: String) -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        return components.queryItems?.first { $0.name == name }?.value
    }
}


//  MARK: - UIApplication
extension UIApplication {
    
    class func topMostViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topMostViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topMostViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topMostViewController(controller: presented)
        }
        return controller
    }
}


//  MARK: - UIImageView
public extension UIImageView {
    
    /**
     Get playPORTAL image by id and set as `UIImageView.image`.
     
     - Parameter forImageId: Id corresponding to playPORTAL image.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     
     - Returns: Void
     */
    func playPortalImage(forImageId imageId: String?, _ completion: ((_ error: Error?) -> Void)?) -> Void {
        guard let imageId = imageId else {
            return
        }
        PlayPortalImage.shared.getImage(forImageId: imageId) { [weak self] error, data in
            guard error == nil else {
                completion?(error)
                return
            }
            guard let strongSelf = self
                , let data = data
                , let image = UIImage(data: data)
                else {
                    completion?(PlayPortalError.API.requestFailedForUnknownReason(message: "Unable to deserialize image data."))
                    return
            }
            strongSelf.image = image
            completion?(nil)
        }
    }
    
    /**
     Get playPORTAL profile pic by id and set as `UIImageView.image`.
     If profile pic id is nil or the image is unable to be requested, will use a default image.
     
     - Parameter forImageId: Id corresponding to the playPORTAL user's profile pic; if image is nil, use a default image.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     
     - Returns: Void
     */
    func playPortalProfilePic(forImageId imageId: String?, _ completion: ((_ error: Error?) -> Void)?) -> Void {
        guard let imageId = imageId else {
            image = Utils.getImageAsset(byName: "anonUser")
            return
        }
        PlayPortalImage.shared.getImage(forImageId: imageId) { [weak self] error, data in
            guard error == nil else {
                completion?(error)
                return
            }
            guard let strongSelf = self
                , let data = data
                , let image = UIImage(data: data)
                else {
                    self?.image = Utils.getImageAsset(byName: "anonUser")
                    completion?(PlayPortalError.API.requestFailedForUnknownReason(message: "Unable to deserialize image data."))
                    return
            }
            strongSelf.image = image
            completion?(nil)
        }
    }
    
    /**
     Get playPORTAL cover photo by id and set as `UIImageView.image`.
     If cover photo id is nil or the image is unable to be requested, will use a default image.
     
     - Parameter forImageId: Id corresponding to the playPORTAL user's cover photo; if image is nil, use a default image.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     
     - Returns: Void
     */
    func playPortalCoverPhoto(forImageId imageId: String?, _ completion: ((_ error: Error?) -> Void)?) -> Void {
        guard let imageId = imageId else {
            image = Utils.getImageAsset(byName: "anonUserCover")
            return
        }
        PlayPortalImage.shared.getImage(forImageId: imageId) { [weak self] error, data in
            guard error == nil else {
                completion?(error)
                return
            }
            guard let strongSelf = self
                , let data = data
                , let image = UIImage(data: data)
                else {
                    self?.image = Utils.getImageAsset(byName: "anonUserCover")
                    completion?(PlayPortalError.API.requestFailedForUnknownReason(message: "Unable to deserialize image data."))
                    return
            }
            strongSelf.image = image
            completion?(nil)
        }
    }
}
