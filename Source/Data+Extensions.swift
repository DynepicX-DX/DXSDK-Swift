//
//  Data+Extensions.swift
//
//  Created by Lincoln Fraley on 10/31/18.
//

import Foundation

//  Simplify converting Data to json and array of json
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
}
