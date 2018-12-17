//
//  Events.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 12/10/18.
//

import Foundation

enum Event {
    
    case authenticated(accessToken: String, refreshToken: String)
    case loggedOut(error: Error?)
    case firstRun
}

protocol EventSubscriber {
    
    func on(event: Event)
}

class EventHandler {
    
    static let shared = EventHandler()
    private let queue = DispatchQueue(label: "com.dynepic.playPORTAL.EventHandlerQueue", attributes: .concurrent)
    private let subscribers = Synchronized<[EventSubscriber]>(value: [])
    
    func subscribe(_ subscriber: EventSubscriber) {
        subscribers.value = subscribers.value + [subscriber]
    }
    
    func publish(_ event: Event) {
        for subscriber in subscribers.value {
            subscriber.on(event: event)
        }
    }
}
