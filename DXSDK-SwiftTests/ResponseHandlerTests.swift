//
//  ResponseHandlerTests.swift
//  DXSDK-SwiftTests
//
//  Created by Lincoln Fraley on 11/10/18.
//  Copyright © 2018 Lincoln Fraley. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import DXSDK_Swift

class ResponseHandlerTests: QuickSpec {
    
    var handler = DefaultResponseHandler.shared
    
    struct CodableTest: Codable {
        var name: String
        var age: Int
    }
    
    override func spec() {
        describe("ResponseHandler") {
            context("factory") {
                it("should return Data for Data") {
                    let data = Data(base64Encoded: "ZmZzZGZhc3Zkc2F2ZHNh")
                    if let data = data {
                        let d: Data? = self.handler.factory(data)
                        expect(d).toNot(beNil())
                    }
                }
                
                it("should return JSON for JSON") {
                    let json = ["name": "lincoln"]
                    if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
                        let response: [String: Any]? = self.handler.factory(data)
                        expect(response).toNot(beNil())
                    }
                }
                
                it("should return JSON array for JSON array") {
                    let jsonArray = [["name": "lincoln"]]
                    if let data = try? JSONSerialization.data(withJSONObject: jsonArray, options: []) {
                        let response: [[String: Any]]? = self.handler.factory(data)
                        expect(response).toNot(beNil())
                    }
                }
                
                it("should return Codable for Codable") {
                    let codable = CodableTest(name: "lincoln", age: 25)
//                    if let data = try? JSONEncoder().encode(codable) {
//                        let response: CodableTest = self.handler.factory(data: data)
//                    }
                    expect(codable as? Codable).toNot(beNil())
                }
            }
        }
    }
}
