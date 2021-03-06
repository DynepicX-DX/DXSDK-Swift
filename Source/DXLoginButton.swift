//
//  DXLoginButton.swift
//
//  Created by Gary J. Baldwin on 9/12/18.
//  Copyright © 2018 Dynepic. All rights reserved.
//

import Foundation
import UIKit

public enum DXLoginButtonImage: String {
  
    case dark = "SSOButtonDark"
    case gradient = "SSOButtonGradient"
    case light = "SSOButtonLight"
    case solid = "SSOButtonSolid"
}

//  Responsible for initializing SSO flow when tapped.
public final class DXLoginButton: UIButton {
  
  private weak var from: UIViewController?
  
  /**
   Create login button.
   
   - Parameter from: UIViewController that will present SFSafariViewController; defaults to topmost UIViewController.
   - Parameter image: Image to use for login button.
   */
  public init(from viewController: UIViewController? = nil, image: DXLoginButtonImage) {
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
    
    addTarget(self, action: #selector(DXLoginButton.loginTapped), for: .touchUpInside)
    
    //  Set image
    guard let image = Utils.getImageAsset(byName: image.rawValue) else { return }
    let ssoButtonImage = UIImageView(image: image)
    ssoButtonImage.frame = bounds
    ssoButtonImage.contentMode = .scaleAspectFit
    addSubview(ssoButtonImage)
    sendSubviewToBack(ssoButtonImage)
  }
  
  internal required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /**
   When DXLoginButton is tapped, SSO flow will begin.
   
   - Returns: Void
   */
  @objc func loginTapped() {
    DXAuthClient.shared.login(from: from)
  }
}
