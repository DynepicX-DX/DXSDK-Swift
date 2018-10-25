//
//  PPLoginButton.swift
//  PlayPortal
//
//  Created by Gary J. Baldwin on 9/12/18.
//  Copyright © 2018 Dynepic. All rights reserved.
//

import Foundation
import UIKit

//  This protocol should be implemented by the UIViewController using the PlayPortalLoginButton.
//  It includes methods for handling errors during playPORTAL SSO.
public protocol PlayPortalLoginDelegate: class {
    
    /**
     Called when an error occurs during SSO flow.
     
     - Parameter loginButton: The PlayPortalLoginButton that was used.
     - Parameter error: The error that occurred.
     
     - Returns: Void
    */
    func playPortalLoginButtonDidFinishWithError(_ loginButton: PlayPortalLoginButton, error: Error) -> Void 
}


/**
 Responsible for initializing SSO flow when tapped.
 */
public class PlayPortalLoginButton: UIButton {
    
    //  MARK: - Properties
    
    //  Handles playPORTAL SSO errors
    private weak var delegate: PlayPortalLoginDelegate?
    
    //  The UIViewController to present the SSO web view
    private weak var from: UIViewController?
    
    
    //  MARK: - Initializers
    
    /**
     Create login button.
     
     - Parameter delegate: PlayPortalLoginDelegate that will handle playPORTAL SSO errors.
     - Parameter from: UIViewController that will present SFSafariViewController; defaults to topmost UIViewController.
    */
    public init(
        delegate: PlayPortalLoginDelegate? = nil,
        from viewController: UIViewController? = nil
    ) {
        self.delegate = delegate
        self.from = viewController
        
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
            , let image = UIImage(named: "SSOButton", in: resourceBundle, compatibleWith: traitCollection)
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
    
    
    //  MARK: - Methods
    
    /**
     When PlayPortalLoginButton is tapped, SSO flow will begin.
     
     - Returns: Void
    */
    @objc func loginTapped() {
        do {
            try PlayPortalAuth.shared.login(from: from)
        } catch {
            delegate?.playPortalLoginButtonDidFinishWithError(self, error: error)
        }
    }
}
