//
//  ViewController.swift
//  Messenger478
//
//  Created by Harrison Balogh on 10/10/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Cocoa
import Security

class ViewController: NSViewController {

    enum tag_error: Error {
        case InvalidInput(String)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func prng(keysize: Int) -> Int {
        return 0
    }
    
    //data types for c, tag, c2 should be changed
    func encryptor(plain_text: String, key: Int) -> [String:Any] {
        let keysize = 0
        let key = prng(keysize: 10)
        let IV = prng(keysize: 10)
        var c = 0   //c = AESe(message, IV, key, CBC)
        let key2 = prng(keysize: 10)
        var tag = 0 //tag = HMAC(c, key2)
        var c2 = 0  //c2 = rsa_pkb2(key || key2)
        let jsonObject: [String: Any] = [
            "cipher": c,
            "IV": IV,
            "tag": tag,
            "c2": c2
        ]
        return jsonObject
    }
    
    func decryptor(cipher_text: [String:Any], key_pair: Int) throws -> String {
        let plaintext = ""
        var tag = ""        //find in cipher_text
        //key,key2 = rsa_prb(c2), OAEP with 2048 bit key size, load private key
        //decrypt RSA ciphertext, recover 256 bit keys for AES and HMAC
        var tag_new = ""    //tag' = HMAC(c, key2) SHA-256 with hmac key
        if tag_new != tag {
            throw tag_error.InvalidInput("error")
        }
        //m = AESd(c, IV, key, CBC)
        return plaintext
    }
}

