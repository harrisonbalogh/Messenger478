//
//  ViewController.swift
//  Messenger478
//
//  Created by Harrison Balogh on 10/10/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var textfield_message: NSTextField!
    @IBOutlet weak var textField_encrypted: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func action_encryptTextField(_ sender: NSTextField) {
        
//        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
//        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
//        CC_MD5_Init(context)
//        CC_MD5_Update(context, sender.stringValue,
//                      CC_LONG(sender.stringValue.lengthOfBytes(using: String.Encoding.utf8)))
//        CC_MD5_Final(&digest, context)
//        context.deallocate(capacity: 1)
//        var hexString = ""
//        for byte in digest {
//            hexString += String(format:"%02x", byte)
//        }
//        textField_encrypted.stringValue = hexString
//        
//        if encrypting {
//            
//        } else {
//            
//        }
        
        // Retrieve Public Key BIO
//        let publicKey = getPublicKey()
//        print("'\(publicKey)'")

        let publicKey = "Hello World"
        

        
        let str = UnsafeMutablePointer<CChar>.allocate(capacity: Int(strlen(publicKey)))
        str.initialize(to: 0)
        
        let bufferPointer = UnsafeBufferPointer(start: str, count: Int(strlen(publicKey)))
        for (index, value) in bufferPointer.enumerated() {
            print("value \(index): \(value)")
        }

        
        defer {
            str.deinitialize(count: Int(strlen(publicKey)))
            str.deallocate(capacity: Int(strlen(publicKey)))
        }
        
        enc()
        
        let publicBIO: UnsafeMutablePointer<BIO> = BIO_new_mem_buf(publicKey, -1)
        
//        let message = sender.stringValue
//        let data = message.data(using: String.Encoding.utf8)
        
        // Get Public Key
//        let readPublicKey = getPublicKey()
//        print(readPublicKey)
//        var publicKey = UnsafeMutablePointer<Int>.allocate(capacity: readPublicKey.characters.count)
//        var pubKey = [UInt8](repeating: 0, count: readPublicKey.characters.count)
//        var remainder = UnsafeMutablePointer<Range<String.Index>>.allocate(capacity: 20)
//        remainder.initialize(to: readPublicKey.startIndex..<readPublicKey.endIndex)
//        let _ = readPublicKey.getBytes(&pubKey, maxLength: readPublicKey.characters.count, usedLength: publicKey, encoding: .utf8, range: readPublicKey.startIndex..<readPublicKey.endIndex, remaining: remainder)
//        print(pubKey)

        
//        let bufferPointer = UnsafeBufferPointer(start: publicBIO, count: readPublicKey.characters.count)
//        for (index, value) in bufferPointer.enumerated() {
//            print("value \(index): \(value)")
//        }
        
//        if let rsa_publicKey = PEM_read_bio_RSAPublicKey(publicBIO, nil, nil, nil) {
            // success
//        } else {
//            ERR_load_crypto_strings()
//            
//            let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: 500)
//            buffer.initialize(to: 0, count: 500)
//            defer {
//                buffer.deinitialize(count: 500)
//                buffer.deallocate(capacity: 500)
//            }
//            ERR_error_string(ERR_get_error(), buffer)
//            print(String(cString: buffer))
//        }
//        BIO_free(publicBIO)
        
//        readPublicKey.getBytes(&<#T##buffer: [UInt8]##[UInt8]#>, maxLength: readPublicKey.characters.count, usedLength: <#T##UnsafeMutablePointer<Int>#>, encoding: .utf8, range: <#T##Range<String.Index>#>, remaining: <#T##UnsafeMutablePointer<Range<String.Index>>#>)
//        let ptr: UnsafeMutablePointer<Character> = readPublicKey.getBytes(&<#T##buffer: [UInt8]##[UInt8]#>, maxLength: <#T##Int#>, usedLength: <#T##UnsafeMutablePointer<Int>#>, encoding: <#T##String.Encoding#>, range: <#T##Range<String.Index>#>, remaining: <#T##UnsafeMutablePointer<Range<String.Index>>#>)
//        let bioPub: UnsafeMutablePointer<BIO> = BIO_new_mem_buf(publicKey, Int32(publicKey.characters.count))
//        let rsaPubKey: UnsafeMutablePointer<RSA> = PEM_read_bio_RSA_PUBKEY(bioPub, nil, nil, nil)
//        BIO_free(bioPub)
        
//        print(rsaPubKey)
        
        // Get Private Key
//        let privateKey = getPrivateKey()
//        print(privateKey)
//        let bioPri = BIO_new_mem_buf(privateKey, Int32(privateKey.characters.count))
//        let rsaPriKey = PEM_read_bio_RSAPrivateKey(bioPri, nil, nil, nil)
//        
//        BIO_free(bioPri)
//        
        // Buffer
//        let maxSize = RSA_size(rsaPubKey)
        
    }
    
    func getPublicKey() -> String {
//        let startString = "-----BEGIN PUBLIC KEY-----"
//        let endString   = "-----END PUBLIC KEY-----"
        if let path = Bundle.main.path(forResource: "public", ofType: "pem") {
            do {
//                var publicKey = ""
//                let url = URL(fileURLWithPath: path)
                let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
//                if
//                    let indexStart = content.range(of: startString),
//                    let indexEnd = content.range(of: endString) {
//                    let range = indexStart.upperBound..<indexEnd.lowerBound
//                    publicKey = content.substring(with: range).trimmingCharacters(in: .whitespacesAndNewlines)
//                }
//                let content = try Data(contentsOf: url)
                
                return content//.base64EncodedString(options: .init(rawValue: 0))
            } catch { }
        }
        return ""
    }
    func getPrivateKey() -> String {
        let startString = "-----BEGIN RSA PRIVATE KEY-----"
        let endString   = "-----END RSA PRIVATE KEY-----"
        if let path = Bundle.main.path(forResource: "private", ofType: "pem") {
            do {
                var privateKey = ""
                let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                if
                    let indexStart = content.range(of: startString),
                    let indexEnd = content.range(of: endString) {
                    let range = indexStart.upperBound..<indexEnd.lowerBound
                    privateKey = content.substring(with: range).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                return privateKey
            } catch { }
        }
        return ""
    }
    
    @IBOutlet weak var howToLabel: NSTextField!
    var encrypting = false
    @IBAction func action_encryptCheckBox(_ sender: NSButton) {
        if sender.title == "Encrypt" {
            encrypting = true
            howToLabel.stringValue = "- Press enter to encrypt -"
        } else {
            encrypting = false
            howToLabel.stringValue = "- Press enter to decrypt -"
        }
    }
}
