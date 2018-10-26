//
//  UIImageView+playPortalImageFromId.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 10/25/18.
//

import Foundation
import UIKit

//  Extension on `UIImageView` that will set the image based on an image id
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
            guard let strongSelf = self
                , let data = data
                , let image = UIImage(data: data)
                else {
                    completion?(error)
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
            image = Utils.getImageAsset(byName: "AnonUser")
            return
        }
        PlayPortalImage.shared.getImage(forImageId: imageId) { [weak self] error, data in
            guard let strongSelf = self
                , let data = data
                , let image = UIImage(data: data)
                else {
                    self?.image = Utils.getImageAsset(byName: "AnonUser")
                    completion?(error)
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
            image = Utils.getImageAsset(byName: "AnonUserCover")
            return
        }
        PlayPortalImage.shared.getImage(forImageId: imageId) { [weak self] error, data in
            guard let strongSelf = self
                , let data = data
                , let image = UIImage(data: data)
                else {
                    self?.image = Utils.getImageAsset(byName: "AnonUserCover")
                    completion?(error)
                    return
            }
            strongSelf.image = image
            completion?(nil)
        }
    }
}
