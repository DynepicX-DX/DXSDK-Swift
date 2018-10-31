//
//  URLRequest+Extensions.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 10/31/18.
//

import Foundation

//  Simplify creating a url request
internal extension URLRequest {
    
    /**
     Factory method for creating `URLRequest`.
     
     - Parameter method: Request method.
     - Parameter andURL: URL of request.
     - Parameter andBody: Request body.
     - Parameter andQueryParams: URL query parameters.
     - Parameter andHeaders: Request headers.
     
     - Returns: `URLRequest` if it's able to be created successfully.
    */
    internal static func from(
        method: String,
        andURL urlString: String,
        andBody body: [String: Any?]? = nil,
        andQueryParams queryParams: [String: String?]? = nil,
        andHeaders headers: [String: String]? = nil)
        -> URLRequest?
    {
        var url = URL(string: urlString)
        if let queryParams = queryParams {
            var params = [String: String]()
            for (key, value) in queryParams where value != nil {
                params[key] = value!
            }
            url = url?.with(queryParams: params)
        }
        
        guard url != nil else { return nil }
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = method
        
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
        
        if let headers = headers {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return nil
    }
}
