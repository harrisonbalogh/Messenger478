//
//  ServerConnection.swift
//  Messenger478
//
//  Created by Harrison Balogh on 10/10/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Foundation
import JWT
import CryptoSwift
import Starscream

class MessengerConnection {
    
    static var session_jwt = "" {
        didSet {
            print("JWT: \(session_jwt)")
        }
    }
    
    private static let defaultSession = URLSession(configuration: .default)
    private static var dataTask: URLSessionDataTask?
    
    /**
     Login user and return a JWT if username and password are correct. Returns a completion
     handler with success of login.
    */
    static func login(user: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        
        // Post username to login1
        api_call(method: .POST, route: .login1, body: "name="+user) {
            (json: [String: Any]) in
            // Check login1 found username
            if json["success"] is Int {
                completion(false)
                return
            }
            // Returns salt and challenge
            guard let salt = json["salt"],
                  let challenge = json["challenge"] else {return}
            // Prepare HMAC with SHA256(password || salt) and challenge
            let passSaltData: Array<UInt8> = Array((password+"\(salt)").sha256().utf8)
            let challengeData: Array<UInt8> = Array("\(challenge)".utf8)
            do {
                let hmac = try HMAC(key: passSaltData, variant: .sha256).authenticate(challengeData)
                // Send back the HMAC and username.
                api_call(method: .POST, route: .login2, body: "name=\(user)&tag=\(hmac.toHexString())") {
                    (json: [String: Any]) in
                    
                    guard let success = json["success"] as? Int else {return}
                    if success == 1 {
                        guard let jwt = json["token"] as? String else {return}
                        session_jwt = jwt
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } catch {}
        }
    }
    
    /**
        Returns a completion handler with success of registration
    */
    static func register(user: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        
        // Post username and password to register
        api_call(method: .POST, route: .register, body: "name=\(user)&password=\(password)") {
            (json: [String: Any]) in
            
            guard let success = json["success"] as? Int else {return}
            if success == 1 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - API Calls
    
    enum User_API_Route {
        case login1
        case login2
        case register
    }
    enum HTTP_Method {
        case POST
        case GET
    }
    private static let DOMAIN_ADDRESS = "https://www.hm478project.me/"
    /**
     Body should be in the form of "name=User1&password=MyPassword" etc.
    */
    private static func api_call(method: HTTP_Method, route: User_API_Route, body: String, completion: @escaping (_ json: [String: Any]) -> Void) {
        // Setup
        if let urlComponents = URLComponents(string: DOMAIN_ADDRESS + "\(route)/") {
            guard let url = urlComponents.url else { return }
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "\(method)"
            request.httpBody = body.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    // Network error
                    print("error=\(String(describing: error))")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                    // HTTP error
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        completion(json)
                    }
                } catch {}
            }
            task.resume()
        }
    }
}



















