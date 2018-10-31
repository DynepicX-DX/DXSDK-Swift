//
//  PlayPortalUtils.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 10/31/18.
//

import Foundation
import UIKit
import StoreKit

//  Publicly available utility functions
public final class PlayPortalUtils {
    
    //  MARK: - Initializers
    
    //  Should not be initialized; all methods are static
    private init() {}
    
    
    //  MARK: - Methods
    
    /**
     Opens playPORTAl on user's phone if downloaded or opens app store for user to download it.
     
     - Parameter from: The view controller to open `SKStoreProductViewController` from; defaults to top most view controller.
     - Parameter completion: The closure invoked after loading playPORTAL with StoreKit.
     - Parameter error: The error returned if playPORTAL is unable to be loaded.
     
     - Returns: Void
    */
    public static func openOrDownloadPlayPORTAL(from: UIViewController? = nil, _ completion: ((_ error: Error?) -> Void)? = nil) -> Void {
        
        //  Attempt to open playPORTAL
        if let playPortalURL = URL(string: "playportal://") , UIApplication.shared.canOpenURL(playPortalURL) {
            UIApplication.shared.open(playPortalURL, options: [:], completionHandler: nil)
        } else {
            //  Otherwise, open playPORTAL through StoreKit
            let storeProductVC = SKStoreProductViewController()
            let params = [
                SKStoreProductParameterITunesItemIdentifier: "com.dynepic.iOKids"
            ]
            storeProductVC.loadProduct(withParameters: params) { _, error in
                storeProductVC.dismiss(animated: true, completion: nil)
                completion?(error)
            }
            let openFrom = from ?? UIApplication.topMostViewController()
            openFrom?.present(storeProductVC, animated: true, completion: nil)
        }
    }
}
