//
//  MasterProtocol.swift
//  Messenger478
//
//  Created by Harrison Balogh on 12/4/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Foundation

protocol LoginDelegate {
    func loginWasSuccessful(for username: String)
    func logout()
}
