//
//  URL+withQueryParams.swift
//
//  Created by Lincoln Fraley on 10/24/18.
//

import Foundation

//  Simplify adding query params to a url
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
