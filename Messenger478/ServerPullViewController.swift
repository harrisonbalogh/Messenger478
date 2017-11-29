//
//  ServerPullViewController.swift
//  Messenger478
//
//  Created by Harrison Balogh on 11/14/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Cocoa
import JWT

class ServerPullViewController: NSViewController {

    @IBOutlet var messageTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func action_refreshButton(_ sender: NSButton) {
        //MessengerConnection.post(message: "Hello there. This is a message")
        MessengerConnection.getAllMessages() {
            (output: String) in
            
            DispatchQueue.main.async {
                self.messageTextView.string = output
            }
        }
    }

    @IBAction func action_updateJWTButton(_ sender: NSButton) {
//        JWT.encode(claims: ["my": "paylod"], algorithm: .hs256("secret".data(using: .utf8)!))
    }
}
