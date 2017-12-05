//
//  MessageViewController.swift
//  Messenger478
//
//  Created by Harrison Balogh on 12/3/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Cocoa
import Starscream
import SocketIO

class MessageViewController: NSViewController, WebSocketDelegate {
    
    var loginDelegate: LoginDelegate?
    
    @IBOutlet var messageTextView: NSTextView!
    @IBOutlet weak var sendTextField: NSTextField!
    @IBOutlet weak var userTextField: NSTextField!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        connectSocket()
    }
    
    
    // MARK: - Handle UI
    
    @IBAction func action_logout(_ sender: NSButton) {
        loginDelegate?.logout()
    }
    
    @IBAction func action_send(_ sender: NSTextField) {
        if socket != nil {
            socket.emit("message", sender.stringValue);
            sender.stringValue = ""
        }
    }
    
    // MARK: - Web Socket Delegate Functions
//    var socket: WebSocketClient!
    var socket: SocketIOClient!
    var manager: SocketManager!
    
    private let DOMAIN_ADDRESS = "https://www.hm478project.me/messages"
    /**
     
     */
    private func connectSocket() {
//        socket = WebSocket(url: URL(string: DOMAIN_ADDRESS)!)
//        socket.enabledSSLCipherSuites = [
//            TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384,
//            TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
//            TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,
//            TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
//        ]
//        socket.delegate = self
//        socket.connect()
        
        manager = SocketManager(socketURL: URL(string: DOMAIN_ADDRESS)!, config: [.log(true), .compress]) // .extraHeaders(["token": MessengerConnection.session_jwt])
        socket = manager.defaultSocket

//        socket.on("success") { data, ack in
//            print("Succes??!?!")
//        }

        socket.on(clientEvent: .connect) {data, ack in
            print("================== SOCKET CONNECTED ==================")
            self.socket.emit("authenticate", ["token": MessengerConnection.session_jwt]) //send the jwt
        }
        socket.on("response") { data, ack in
            DispatchQueue.main.async {
                self.messageTextView.string += String(describing: "\(data)\n")
            }
        }
//        socket.on("message") { data, ack in
//            DispatchQueue.main.async {
//                self.messageTextView.string += String(describing: data)
//            }
//            socket.emit("received", ["content": "someContent"]);
//        }
//
//        socket.on("authenticated") { data, ack in
//            print("Auth!!!")
//        }
//        socket.on("unauthorized") { data, ack in
//            print("Unauth!!!")
//        }

//        socket.on("currentAmount") {data, ack in
//            guard let cur = data[0] as? Double else { return }
//
//            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
//                socket.emit("update", ["amount": cur + 2.50])
//            }
//
//            ack.with("Got your currentAmount", "dude")
//        }

        socket.connect()
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("got some text: \(text)")
    }
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
}
