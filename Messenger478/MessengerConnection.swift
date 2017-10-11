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
    
    static func testRetrieve() {
        
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://hm478project.me") {
//            urlComponents.query = "media=music&entity=song&term=someTerm"
            
            guard let url = urlComponents.url else { return }
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                // 5
                if let error = error {
                    print("DataTask error: " + error.localizedDescription + "\n")
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    // use the 'data' here. Have to convert it since its received as a byte stream
                    if let stringData = String(data: data, encoding: .utf8) {
                        print(stringData)
                    }
                    
                }
            }
            self.dataTask?.resume()
        }
    }
    
}
