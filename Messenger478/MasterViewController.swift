//
//  MasterViewController.swift
//  Messenger478
//
//  Created by Harrison Balogh on 12/4/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController, LoginDelegate {

    var loginVC: LoginViewController!
    var messageVC: MessageViewController!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // When the masterVC first appears, it should start with the login display.
        displayLogin()
    }
    
    // MARK: - LoginDelegate: Handle communications from loginVC and displayVC
    func loginWasSuccessful(for username: String) {
        displayMessenger(with: username)
    }
    func logout() {
        displayLogin()
    }
    
    // MARK: - Displays
    /**
     Prepares the key window for the display of the login screen and then
     pushes the loginVC onto the window.
    */
    private func displayLogin() {
        
        // Clear any displayed child view controllers
        for child in self.childViewControllers {
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Instance a new loginVC
        self.loginVC = LoginViewController(nibName: NSNib.Name("LoginView"), bundle: nil)
        
        // Add the loginVC and its view
        self.addChildViewController(loginVC)
        // The login screen is not resizable, so we want to get the key window
        // to the proper size before applying the loginVC constraints to masterVC
        NSApp.keyWindow?.animator().setContentSize(loginVC.view.frame.size)
        self.view.addSubview(self.loginVC.view)
        self.loginVC.view.autoresizingMask = [.width, .height]
        self.loginVC.loginDelegate = self
    }
    /**
     Prepares the key window for the display of the messenger screen and then
     pushes the messageVC onto the window.
    */
    private func displayMessenger(with username: String) {
        
        // Clear any displayed child view controllers
        for child in self.childViewControllers {
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Instance a new messageVC
        self.messageVC = MessageViewController(nibName: NSNib.Name("MessageView"), bundle: nil)
        
        // Add the messageVC and its view
        self.addChildViewController(messageVC)
        // The messenger screen can be resized but it should start off with
        // the default messanger screen size
        NSApp.keyWindow?.animator().setContentSize(messageVC.view.frame.size)
        self.view.addSubview(self.messageVC.view)
        self.messageVC.view.autoresizingMask = [.width, .height]
        self.messageVC.loginDelegate = self
        self.messageVC.userTextField.stringValue = username
    }
}
