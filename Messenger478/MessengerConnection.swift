//
//  ServerConnection.swift
//  Messenger478
//
//  Created by Harrison Balogh on 10/10/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Foundation

class MessengerConnection {
    
    static let defaultSession = URLSession(configuration: .default)
    
    static var dataTask: URLSessionDataTask?
    
    static func getAllMessages(completion: @escaping (_ output: String) -> Void) {
        
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://hm478project.me/tasks/") {
            //urlComponents.query = "media=music&entity=song&term=someTerm"
            
            guard let url = urlComponents.url else { return }
            
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                
            }
            
            dataTask = defaultSession.dataTask(with: url, completionHandler: {data, response, error in
                defer { self.dataTask = nil }
                // 5
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]{
                        completion(parse_getAllMessages(from: json!))
                    }
                    
                    // use the 'data' here. Have to convert it since its received as a byte stream
                    //if let stringData = String(data: data, encoding: .utf8) { }
                    
                }
            })
            
            self.dataTask?.resume()
        }
    }
    
    static func post(message: String) {
        
        if let urlComponents = URLComponents(string: "https://hm478project.me/tasks/") {
            //urlComponents.query = "media=music&entity=song&term=someTerm"
            
            guard let url = urlComponents.url else { return }
            
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            let postString = "name=\(message)"
            
            request.httpBody = postString.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
            }
            task.resume()
        }
    }
    
    // MARK: - Parse API JSON
    
    private static func parse_getAllMessages(from json: [Any]) -> String {
        
        var buildOutput = ""
        
        for element in json {
            guard let jsonDict = element as? [String: Any] else {break}
            if
                let id = jsonDict["_id"] as? String,
                let content = jsonDict["name"] as? String,
                let date = jsonDict["Created_date"] as? String
            {
                buildOutput += id + " - ( " + date + ") " + content + "\n\n"
            }
        }
        
        return buildOutput
    }
    
}
