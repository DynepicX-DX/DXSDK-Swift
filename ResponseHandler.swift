//
//  ResponseHandler.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 11/8/18.
//

import Foundation

let globalResponseHandler = DefaultResponseHandler.shared

protocol ResponseHandler {
    
//    func response<ResponseType>(
//        error: Error?,
//        response: HTTPURLResponse?,
//        data: Data?,
//        _ completion: ((_ error: Error?, _ result: ResponseType.Type?) -> Void)?)
//        -> Void
//
    func dataResponse(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((_ error: Error?, _ data: Data?) -> Void)?)
        -> Void
    
    func jsonResponse(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((_ error: Error?, _ json: [String: Any]?) -> Void)?)
        -> Void
    
    func jsonResponseAtKey(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        key: String,
        _ completion: ((_ error: Error?, _ json: [String: Any]?) -> Void)?)
        -> Void
    
    func jsonArrayResponse(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((_ error: Error?, _ jsonArray: [[String: Any]]?) -> Void)?)
        -> Void
    
    func decodableResponse<D: Codable>(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((_ error: Error?, _ result: D?) -> Void)?)
        -> Void
    
    func decodableArrayResponse<D: Codable>(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((_ error: Error?, _ result: [D]?) -> Void)?)
        -> Void
    
    func handleResponse<ResponseType: Codable>(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((Error?, ResponseType?) -> Void)?)
        -> Void
    
    func handleResponse<ResponseType: Codable>(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        atKey key: String,
        _ completion: ((Error?, ResponseType?) -> Void)?)
        -> Void
}

class DefaultResponseHandler: ResponseHandler {
    
    static let shared = DefaultResponseHandler()
    private init() {}
    
    func handleResponse<ResponseType>(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((Error?, ResponseType?) -> Void)?)
        -> Void
    {
        var result: ResponseType?
        switch ResponseType.self {
        case is Data.Type:
            result = data as? ResponseType
        case is [String: Any].Type:
            result = data?.toJSON as? ResponseType
        case is [[String: Any]].Type:
            result = data?.toJSONArray as? ResponseType
//        case is Codable.Type:
//            
//            result = data?.asDecodable(type: ResponseType.self)
        default:
            break
        }
//        switch true {
//        case ResponseType.self == Data.self:
//            result = data as? ResponseType
//        case ResponseType.self == [String: Codable].self:
//            result = data?.toJSON as? ResponseType
//        case ResponseType.self == [[String: Any]].self:
//            result = data?.toJSONArray as? ResponseType
//        case ResponseType.self == [ResponseType].self:
//            result = data?.toJSONArray?.compactMap { $0.asDecodable(type: ResponseType.self )} as? ResponseType
//        default:
//            result = data?.asDecodable(type: ResponseType.self)
//        }
        let err = (result == nil ? PlayPortalError.API.unableToDeserializeResponse : nil)
            ?? response.map { PlayPortalError.API.createError(from: $0) }
            ?? nil
        completion?(err, result)
    }
    
    func handleResponse<ResponseType: Codable>(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        atKey key: String,
        _ completion: ((Error?, ResponseType?) -> Void)?)
         -> Void
    {
        var json = data?.toJSON
        let keys = key.split(separator: ".").map { String($0) }
        print()
        let one = keys[0..<keys.count - 1]
        print()
        
        let two = one.reduce(json) { result, next in result?[next] as? [String: Any] }
        print()
        json = keys[0..<keys.count - 1].reduce(json) { result, next in result?[next] as? [String: Any] }
        let data = try? JSONSerialization.data(withJSONObject: json, options: [])
        handleResponse(error: error, response: response, data: data, completion)
    }
    
    func dataResponse(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((Error?, Data?) -> Void)?)
        -> Void
    {
        if error != nil {
            let error = response.map { PlayPortalError.API.createError(from: $0) }
                ?? PlayPortalError.API.unableToDeserializeResponse
            completion?(error, nil)
        } else if let data = data {
            completion?(nil, data)
        } else {
            completion?(PlayPortalError.API.unableToDeserializeResponse, nil)
        }
    }
    
    func jsonResponse(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((Error?, [String : Any]?) -> Void)?)
        -> Void
    {
        dataResponse(error: error, response: response, data: data) {
            let result = $1?.toJSON
            let error = result != nil ? nil : $0 ?? PlayPortalError.API.unableToDeserializeResponse
            completion?(error, result)
        }
    }
    
    func jsonResponseAtKey(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        key: String,
        _ completion: ((Error?, [String : Any]?) -> Void)?)
        -> Void
    {
        jsonResponse(error: error, response: response, data: data) { error, json in
            let keys = key.split(separator: ".").map { String($0) }
            let json = keys[0..<keys.count - 1].reduce(json) { $0?[$1] as? [String: Any]}
        }
    }
    
    func jsonArrayResponse(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((Error?, [[String : Any]]?) -> Void)?)
        -> Void
    {
        dataResponse(error: error, response: response, data: data) {
            let result = $1?.toJSONArray
            let error = result != nil ? nil : $0 ?? PlayPortalError.API.unableToDeserializeResponse
            completion?(error, result)
        }
    }
    
    func decodableResponse<D>(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((Error?, D?) -> Void)?)
        -> Void where D : Decodable, D : Encodable
    {
        dataResponse(error: error, response: response, data: data) {
            let result = $1?.asDecodable(type: D.self)
            let error = result != nil ? nil : $0 ?? PlayPortalError.API.unableToDeserializeResponse
            completion?(error, result)
        }
    }
    
    func decodableArrayResponse<D>(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?,
        _ completion: ((Error?, [D]?) -> Void)?)
        -> Void where D : Decodable, D : Encodable
    {
        dataResponse(error: error, response: response, data: data) {
            let result = $1?.toJSONArray?.compactMap { $0.asDecodable(type: D.self )}
            let error = result != nil ? nil : $0 ?? PlayPortalError.API.unableToDeserializeResponse
            completion?(error, result)
        }
    }
}
