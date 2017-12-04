//
//  LoginViewController.swift
//  Messenger478
//
//  Created by Harrison Balogh on 12/3/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    
    var loginDelegate: LoginDelegate?

    // Used to report errors to the user on the login screen.
    @IBOutlet weak var replyLabel: NSTextField!
    @IBOutlet weak var appTitleLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    @IBAction func action_register(_ sender: Any) {
        if usernameField.stringValue.trimmingCharacters(in: .whitespaces) != "" && passwordField.stringValue.trimmingCharacters(in: .whitespaces) != "" {
            if passwordField.stringValue.trimmingCharacters(in: .whitespaces).count < 8 {
                display(message: "Password must be at least 8 characters.")
            } else {
                progressIndicator.isHidden = false
                progressIndicator.startAnimation(self)
                MessengerConnection.register(user: usernameField.stringValue, password: passwordField.stringValue) {
                    (success: Bool) in
                    DispatchQueue.main.async {
                        self.progressIndicator.isHidden = true
                        self.progressIndicator.stopAnimation(self)
                    }
                    if success {
                        self.display(message: "New user created. Login with your new credentials.")
                    } else {
                        self.display(message: "That username is taken.")
                    }
                }
            }
        } else {
            display(message: "You must enter a username and password.")
        }
    }
    
    @IBAction func action_username(_ sender: NSTextField) {
        if usernameField.stringValue.trimmingCharacters(in: .whitespaces) != "" {
            NSApp.keyWindow?.makeFirstResponder(passwordField)
        }
    }
    @IBAction func action_password(_ sender: NSSecureTextField) {
        if usernameField.stringValue.trimmingCharacters(in: .whitespaces) == "" {
            NSApp.keyWindow?.makeFirstResponder(usernameField)
        } else {
            action_login(self)
        }
    }
    @IBAction func action_login(_ sender: Any) {
        if usernameField.stringValue.trimmingCharacters(in: .whitespaces) != "" && passwordField.stringValue.trimmingCharacters(in: .whitespaces) != "" {
            progressIndicator.isHidden = false
            progressIndicator.startAnimation(self)
            MessengerConnection.login(user: usernameField.stringValue, password: passwordField.stringValue) {
                (success: Bool) in
                DispatchQueue.main.async {
                    self.progressIndicator.isHidden = true
                    self.progressIndicator.stopAnimation(self)
                }
                if success {
                    self.display(message: "Login successful.")
                    DispatchQueue.main.async {
                        self.loginDelegate?.loginWasSuccessful(for: self.usernameField.stringValue)
                    }
                } else {
                    self.display(message: "Incorrect username or password entered.")
                }
            }
        } else {
            display(message: "You must enter a username and password.")
        }
    }
    
    // MARK: - Error Output
    /// Temporarily displays a message to user.
    func display(message: String) {
        display(message: message, duration: 4)
    }
    func display(message: String, duration: TimeInterval) {
        DispatchQueue.main.async {
            self.replyLabel.stringValue = message
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = 0.5
            NSAnimationContext.current.completionHandler = {
                self.perform(#selector(self.resetDisplay), with: nil, afterDelay: duration)
            }
            self.appTitleLabel.animator().alphaValue = 0
            self.replyLabel.animator().alphaValue = 1
            NSAnimationContext.endGrouping()
        }
    }
    @objc func resetDisplay() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.5
        appTitleLabel.animator().alphaValue = 1
        replyLabel.animator().alphaValue = 0
        NSAnimationContext.endGrouping()
    }
}
