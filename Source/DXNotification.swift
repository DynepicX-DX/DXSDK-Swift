//
//  DXNotification.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 12/28/18.
//

import Foundation

//  Struct representing a playPORTAL notification
public struct DXNotification: Codable {
  
  public let notificationId: String
  public let text: String
  public let sender: String
  public let acknowledged: Bool
  
  private init() {
    fatalError("`DXNotification` instance should only be initialized by decoding.")
  }
}

extension DXNotification: Equatable {
  
  public static func ==(lhs: DXNotification, rhs: DXNotification) -> Bool {
    return lhs.notificationId == rhs.notificationId
  }
}
