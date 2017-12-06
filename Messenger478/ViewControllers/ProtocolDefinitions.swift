//
//  MasterProtocol.swift
//  Messenger478
//
//  Created by Harrison Balogh on 12/4/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Foundation
import Cocoa

protocol LoginDelegate {
    func loginWasSuccessful(for username: String)
    func logout()
}

protocol RequestDelegate {
    func requestApproved(for name: String)
    func requestDeclined(for name: String)
}
