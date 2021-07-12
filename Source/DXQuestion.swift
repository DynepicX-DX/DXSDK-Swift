//
//  DXQuestion.swift
//  DXSDK-Swift
//
//  Created by Joshua Paulsen on 7/12/21.
//  Copyright © 2021 Lincoln Fraley. All rights reserved.
//

import Foundation

public struct DXQuestion: Codeable {
    
    public let requestingUserId: String
    public let courseId: String
    public let showRemoved: Bool
    
}
