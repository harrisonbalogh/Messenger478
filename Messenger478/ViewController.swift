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

    @IBOutlet weak var textfield_message: NSTextField!
    
    @IBOutlet weak var encryptedTextViewCenteredLabel: NSTextField!
    @IBOutlet var textView_encrypted: NSTextView!
    @IBOutlet weak var encryptButton: NSButton!
    @IBOutlet weak var copyResultButton: NSButton!
    
    var encrypting = true

    enum tag_error: Error {
        case InvalidInput(String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        encryptedTextViewCenteredLabel.alphaValue = 0
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func action_encryptButton(_ sender: NSButton) {
        action_encryptTextField(textfield_message)
    }
    @IBAction func action_copyResultButton(_ sender: NSButton) {
        
    }

    var holdData: Data!
    @IBAction func action_encryptTextField(_ sender: NSTextField) {
        
        // Get message to encrypt ==============================================
        
        var iv = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        iv.initialize(to: 0)
        defer {
            // defer block is called once execution leaves current scope
            iv.deinitialize(count: 16)
            iv.deallocate(capacity: 16)
        }
        if RAND_bytes(iv, 16) != 1 {
            // failed to get CSPRNG
            return
        }
        holdData = sender.stringValue.data(using: .utf8)!
        let data = sender.stringValue.data(using: .utf8)!
        let message = UnsafeMutablePointer<UInt8>.allocate(capacity: 16 + data.count)
        let dataCast = [UInt8](data)
        message.initialize(to: 0, count: 16 + data.count)
        defer {
            message.deinitialize(count: 16 + data.count)
            message.deallocate(capacity: 16 + data.count)
        }
        // Prefix the IV to the message (in bytes)
        for index in 0..<16 {
            print("IV \(index): \(iv.advanced(by: index).pointee)")
            message.advanced(by: index).pointee = iv.advanced(by: index).pointee
        }
        for index in 16..<(data.count+16) {
            message.advanced(by: index).pointee = dataCast[index - 16]
            print("Original message \(index): \(message.advanced(by: index).pointee)")
        }
        
        // Store encrypted results =============================================
        
        var outMessage = UnsafeMutablePointer<UInt8>.allocate(capacity: 16 + data.count)
        outMessage.initialize(to: 0)
        defer {
            outMessage.deinitialize(count: 16 + data.count)
            outMessage.deallocate(capacity: 16 + data.count)
        }
        
        var outMAC = UnsafeMutablePointer<UInt8>.allocate(capacity: 500)
        outMAC.initialize(to: 0)
        defer {
            outMAC.deinitialize(count: 500)
            outMAC.deallocate(capacity: 500)
        }
        
        var hmacLength = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        hmacLength.initialize(to: 0)
        defer {
            hmacLength.deinitialize(count: 1)
            hmacLength.deallocate(capacity: 1)
        }
        
        var outKeys = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(RSA_size(publicRSAKey())))
        outKeys.initialize(to: 0)
        defer {
            outKeys.deinitialize(count: Int(RSA_size(publicRSAKey())))
            outKeys.deallocate(capacity: Int(RSA_size(publicRSAKey())))
        }
        
        var rsaEncKeysLength = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        rsaEncKeysLength.initialize(to: 0)
        defer {
            rsaEncKeysLength.deinitialize(count: 1)
            rsaEncKeysLength.deallocate(capacity: 1)
        }
        

        encrypt(sender, message: message, messageLength: 16 + data.count,
                encryptedMessage: outMessage,
                encryptedKeys: outKeys,
                rsaEncKeysLength: rsaEncKeysLength,
                hmac: outMAC,
                hmacLength: hmacLength)

        decrypt(sender, dataLength: 16 + data.count,
                encryptedMessage: outMessage,
                encryptedKeys: outKeys,
                rsaEncKeysLength: rsaEncKeysLength,
                hmac: outMAC,
                hmacLength: hmacLength)
        
    }
    
    func encrypt(_ sender: NSTextField, message: UnsafePointer<UInt8>, messageLength: Int,
                 encryptedMessage out: UnsafeMutablePointer<UInt8>,
                 encryptedKeys keys: UnsafeMutablePointer<UInt8>,
                 rsaEncKeysLength: UnsafeMutablePointer<Int32>,
                 hmac: UnsafeMutablePointer<UInt8>,
                 hmacLength: UnsafeMutablePointer<UInt32>) {
        if let rsa_publicKey = publicRSAKey() {
            
            // Create AES and IV keys ===========================================
            
            var aesKey = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            aesKey.initialize(to: 0)
            defer {
                // defer block is called once execution leaves current scope
                aesKey.deinitialize(count: 32)
                aesKey.deallocate(capacity: 32)
            }
            RAND_bytes(aesKey, 32)
            
            var aesEncKey = UnsafeMutablePointer<AES_KEY>.allocate(capacity: MemoryLayout<AES_KEY>.size)
            defer {
                // defer block is called once execution leaves current scope
                aesEncKey.deallocate(capacity: MemoryLayout<AES_KEY>.size)
            }
            AES_set_encrypt_key(aesKey, 256, aesEncKey)
            
            // Encrypt message =====================================================
            
            let _ = AES_encrypt(message, out, aesEncKey)
            
            // Generate HMAC integrity tag =========================================
            
            // HMAC key
            var hmacKey = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            hmacKey.initialize(to: 0)
            defer {
                hmacKey.deinitialize(count: 32)
                hmacKey.deallocate(capacity: 32)
            }
            RAND_bytes(hmacKey, 32)
            
            // HMAC context
            let hmacCtx = UnsafeMutablePointer<HMAC_CTX>.allocate(capacity: MemoryLayout<HMAC_CTX>.size)
            defer {
                hmacCtx.deallocate(capacity: MemoryLayout<HMAC_CTX>.size)
            }
            HMAC_CTX_init(hmacCtx)
            
            // Generate HMAC
            HMAC(EVP_sha256(), hmacKey, 32, out, messageLength, hmac, hmacLength)
            HMAC_CTX_cleanup(hmacCtx)
            
            // Concat keys ========================================================
            
            var keys_AES_HMAC = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
            keys_AES_HMAC.initialize(to: 0, count: 64)
            defer {
                // defer block is called once execution leaves current scope
                keys_AES_HMAC.deinitialize(count: 64)
                keys_AES_HMAC.deallocate(capacity: 64)
            }
            for index in 0..<32 {
                keys_AES_HMAC.advanced(by: index).pointee = aesKey.advanced(by: index).pointee
            }
            for index in 32..<64 {
                keys_AES_HMAC.advanced(by: index).pointee = hmacKey.advanced(by: index - 32).pointee
            }
            
            // Encrypt concatted keys ============================================
            
            rsaEncKeysLength.pointee = RSA_public_encrypt(64, keys_AES_HMAC, keys, rsa_publicKey, RSA_PKCS1_OAEP_PADDING)
            
            // Update UI =========================================================
            
            encryptedTextViewCenteredLabel.stringValue = "Encrypted!"
            // Starting animation
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current().duration = 0.2
            encryptedTextViewCenteredLabel.animator().alphaValue = 1
            NSAnimationContext.endGrouping()
            
//            var outString = "== Encrypted HMAC+RSA Keys ==\n\n"
//            
//            for index in 0..<rsaLength {
//                outString += String(format: "%03d", keys.advanced(by: Int(index)).pointee)+"/"
//            }
//            
            var outString = "\n\n== Encrypted Message ==\n\n"
            
            for index in 0..<messageLength {
                outString += "\(out.advanced(by: Int(index)).pointee)\n"
            }
            
//            var outString = "\n\n== HMAC ==\n\n"
//            
//            for index in 0..<Int(hmacLength.pointee) {
//                outString += String(format: "%03d", hmac.advanced(by: Int(index)).pointee)+"\n"
//            }
            
            textView_encrypted.string = outString
            
            copyResultButton.isEnabled = true
        }
    }
    
    func decrypt(_ sender: NSTextField, dataLength: Int,
                 encryptedMessage encMessage: UnsafePointer<UInt8>,
                 encryptedKeys encKeys: UnsafePointer<UInt8>,
                 rsaEncKeysLength: UnsafePointer<Int32>,
                 hmac: UnsafePointer<UInt8>,
                 hmacLength: UnsafeMutablePointer<UInt32>) {
        if let rsa_privateKey = privateRSAKey() {
            
            // Decrypt keys ===========================================================================
            
            var decrypted = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(RSA_size(rsa_privateKey)))
            decrypted.initialize(to: 0)
            defer {
                decrypted.deinitialize(count: Int(RSA_size(rsa_privateKey)))
                decrypted.deallocate(capacity: Int(RSA_size(rsa_privateKey)))
            }
            
            RSA_private_decrypt(rsaEncKeysLength.pointee, encKeys, decrypted, rsa_privateKey, RSA_PKCS1_OAEP_PADDING)
            
            // Split into HMAC and AES keys ============================================================
            
            // AES key decrypted
            var aesKeyDecrypted = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            aesKeyDecrypted.initialize(to: 0)
            defer {
                aesKeyDecrypted.deinitialize(count: 32)
                aesKeyDecrypted.deallocate(capacity: 32)
            }
            
            // HMAC key decrypted
            var hmacKeyDecrypted = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
            hmacKeyDecrypted.initialize(to: 0)
            defer {
                hmacKeyDecrypted.deinitialize(count: 32)
                hmacKeyDecrypted.deallocate(capacity: 32)
            }
            
            for index in 0..<32 {
                aesKeyDecrypted.advanced(by: index).pointee = decrypted.advanced(by: index).pointee
            }
            
            for index in 32..<64 {
                hmacKeyDecrypted.advanced(by: index-32).pointee = decrypted.advanced(by: index).pointee
            }
            
//            var aesEncKeyDecrypted = UnsafeMutablePointer<AES_KEY>.allocate(capacity: MemoryLayout<AES_KEY>.size)
//            defer {
//                // defer block is called once execution leaves current scope
//                aesEncKeyDecrypted.deallocate(capacity: MemoryLayout<AES_KEY>.size)
//            }
//            AES_set_encrypt_key(aesKeyDecrypted, 256, aesEncKeyDecrypted)
            
//            for index in 0..<32 {
//                print("aesEncKeyDecrypted: \(aesKeyDecrypted.advanced(by: index).pointee)")
//            }
            
            // Generate HMAC integrity tag again =======================================================
            
            // HMAC context
            let hmacCtx = UnsafeMutablePointer<HMAC_CTX>.allocate(capacity: MemoryLayout<HMAC_CTX>.size)
            defer {
                hmacCtx.deallocate(capacity: MemoryLayout<HMAC_CTX>.size)
            }
            HMAC_CTX_init(hmacCtx)
            
            // HMAC output
            var outMAC = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(hmacLength.pointee))
            outMAC.initialize(to: 0)
            defer {
                outMAC.deinitialize(count: Int(hmacLength.pointee))
                outMAC.deallocate(capacity: Int(hmacLength.pointee))
            }

            var hmacLengthDecrypted = UnsafeMutablePointer<UInt32>.allocate(capacity: 500)
            hmacLengthDecrypted.initialize(to: 0)
            defer {
                hmacLengthDecrypted.deinitialize(count: 500)
                hmacLengthDecrypted.deallocate(capacity: 500)
            }
            
            // Generate HMAC
            HMAC(EVP_sha256(), hmacKeyDecrypted, 32, encMessage, dataLength, outMAC, hmacLengthDecrypted)
            HMAC_CTX_cleanup(hmacCtx)
            
            // Verify HMAC's match
            if hmacLength.pointee != hmacLengthDecrypted.pointee {
                print("HMAC ERROR: The length of HMAC received does not match the length of HMAC calculated from the encrypted text received.")
                return
            }
            for index in 0..<Int(hmacLength.pointee) {
                if outMAC.advanced(by: index).pointee != hmac.advanced(by: index).pointee {
                    print("    HMAC ERROR: HMAC received does not match the HMAC calculated from the encrypted text received.")
                    return
                }
            }
            
            // Decrypting with AES ==================================================================
            
            // ... Set decrypt key
            var aesDecKey = UnsafeMutablePointer<AES_KEY>.allocate(capacity: MemoryLayout<AES_KEY>.size)
            defer {
                // defer block is called once execution leaves current scope
                aesDecKey.deallocate(capacity: MemoryLayout<AES_KEY>.size)
            }
            AES_set_decrypt_key(aesKeyDecrypted, 256, aesDecKey)
            
            // ... Decrypt with key
            var decryptedMessage = UnsafeMutablePointer<UInt8>.allocate(capacity: dataLength)
            decryptedMessage.initialize(to: 0)
            defer {
                decryptedMessage.deinitialize(count: dataLength)
                decryptedMessage.deallocate(capacity: dataLength)
            }
            
            // problem line:
            let _ = AES_decrypt(encMessage, decryptedMessage, aesDecKey)
            
            // IV
            for index in 0..<16 {
                print("IV \(index): \(decryptedMessage.advanced(by: index).pointee)")
            }
            // Message
            for index in 16..<dataLength {
                print("Decrypted message \(index): \(decryptedMessage.advanced(by: index).pointee)")
            }
        }
    }

    // MARK: - Retrieving Keys from Bundle
    func getPublicKey() -> String {
        if let path = Bundle.main.path(forResource: "public", ofType: "pem") {
            do {
                let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                return content//.base64EncodedString(options: .init(rawValue: 0))
            } catch { }
        }
        return ""
    }
    func getPrivateKey() -> String {
        if let path = Bundle.main.path(forResource: "private", ofType: "pem") {
            do {
                let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                return content
            } catch { }
        }
        return ""
    }
}
