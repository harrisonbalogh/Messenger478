//
//  Message.swift
//  Messenger478
//
//  Created by Harrison Balogh on 11/14/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Foundation

class Message {
    
    let id: String!
    let content: String!
    let created: String!
    
    init(id: String, content: String, created: String) {
        self.id = id
        self.content = content
        self.created = created
    }
}
