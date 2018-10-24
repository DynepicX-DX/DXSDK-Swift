//
//  PPLoginButton.swift
//  PlayPortal
//
//  Created by Gary J. Baldwin on 9/12/18.
//  Copyright © 2018 Dynepic. All rights reserved.
//

import Foundation
import UIKit

/**
 Responsible for initializing auth flow when tapped
 */
public class PlayPortalLoginButton: UIButton {
    
    /**
     Create login button.
    */
    public init() {
        // Width ratio is 279w / 55h
        var buttonWidth: CGFloat = UIScreen.main.bounds.size.width * 0.7
        if buttonWidth > 300 {
            buttonWidth = 300
        }
        let buttonHeight: CGFloat = buttonWidth * (55 / 279)
        let rect = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)

        super.init(frame: rect)
        
        layer.cornerRadius = buttonHeight / 2
        layer.masksToBounds = true
        
        addTarget(self, action: #selector(PlayPortalLoginButton.loginTapped), for: .touchUpInside)
        
        let frameworkBundle = Bundle(for: PlayPortalLoginButton.self)
        guard let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PPSDK-Swift-Assets.bundle")
            , let resourceBundle = Bundle(url: bundleURL)
            , let image = UIImage(named: "anonUser", in: resourceBundle, compatibleWith: traitCollection)
            else { return }
        let ssoButtonImage = UIImageView(image: image)
        ssoButtonImage.frame = bounds
        ssoButtonImage.contentMode = .scaleAspectFit
        addSubview(ssoButtonImage)
        sendSubview(toBack: ssoButtonImage)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func loginTapped() {
//        PPManager.sharedInstance.PPusersvc.login()
    }
}
