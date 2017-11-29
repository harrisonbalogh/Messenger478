//
//  ViewController.swift
//  Messenger478
//
//  Created by Harrison Balogh on 10/10/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Cocoa
import CryptoSwift

class ViewController: NSViewController {
    
    @IBOutlet weak var textfield_message: NSTextField!
    @IBOutlet weak var encryptedTextViewCenteredLabel: NSTextField!
    @IBOutlet var textView_encrypted: NSTextView!
    @IBOutlet weak var encryptButton: NSButton!
    @IBOutlet weak var decryptButton: NSButton!
    
    var encrypting = true

    override func viewDidAppear() {
        super.viewDidAppear()
        encryptedTextViewCenteredLabel.alphaValue = 0
    }
    
    @IBAction func action_encryptButton(_ sender: NSButton) {
        
        // Testing purposes
        encryptedTextViewCenteredLabel.stringValue = "Encrypted"
        encryptedTextViewCenteredLabel.alphaValue = 1
        
        let json: [String: Any] = encrypt(text: sender.stringValue)!
     
//        if let out = String(data: Data(bytes: content_plaintext), encoding: .utf8) {
//            textfield_message.stringValue = "Plaintext: " + out
//        }
    }
    
    @IBAction func action_decryptButton(_ sender: NSButton) {
        
        // Visuals
        encryptedTextViewCenteredLabel.stringValue = "Decrypted"
        encryptedTextViewCenteredLabel.alphaValue = 1

//        let inBytes = lastCipherText!
//
//        let decData = try? CC.RSA.decrypt(Data(bytes: lastRSACipher), derKey: privateKey, tag: Data(bytes: "priv".bytes), padding: .oaep, digest: .sha256)
//        let dec = decData!.0.bytes
//
//        let aesKey = Array(dec[0...31])
//        let hmacKey = Array(dec[32...63])
//
//        do {
//            let content_hmac = try HMAC(key: hmacKey, variant: .sha256).authenticate(inBytes)
//            if lasthmacUsed != content_hmac {
//                // Visuals update
//                textView_encrypted.string = "HMAC's don't match."
//                return
//            }
//
//            let content_plaintext = try AES(key: aesKey, blockMode: .CBC(iv: lastUsedIV)).decrypt(inBytes)
//
//            // Update visuals
//            if let out = String(data: Data(bytes: content_plaintext), encoding: .utf8) {
//                textView_encrypted.string = out
//            }
//
//        } catch { return }
    }
    
    // MARK: - Cipher Module
    
    /**
     Encrypts the provided String using AES-256 bit encryption in
     CBC block mode with a 16 byte IV and PKCS7 padding. An HMAC
     is generated on the ciphertext and the HMAC and AES keys are
     encrypted with RSA.
     
     - parameters:
        - text: The string to be encrypted.
     
     - returns:
        Will return a JSON formatted dictionary. See documentation for
        format. Can return nil if there were any issues generating
        cryptographically secure random keys.
    */
    private func encrypt(text: String) -> [String: Any]? {
        
        let inBytes = text.bytes
        
        guard
            let aesKey = generateSecureKey(of: 32),
            let hmacKey = generateSecureKey(of: 32)
            else { return nil }
        
        let aesIV = AES.randomIV(16)
        
        let content_ciphertext = try! AES(key: aesKey, blockMode: .CBC(iv: aesIV)).encrypt(inBytes)
        let content_hmac = try! HMAC(key: hmacKey, variant: .sha256).authenticate(content_ciphertext)
        
        let keysConcat = aesKey + hmacKey

        let encKeys = try? CC.RSA.encrypt(Data(bytes: keysConcat), derKey: publicKey, tag: Data(bytes: "priv".bytes), padding: .oaep, digest: .sha256)
        
        let jsonObject: [String: Any] = [
            "keys-cipherText": encKeys!.base64EncodedString(),
            "content-cipherText": content_ciphertext.toBase64()!,
            "hmac": content_hmac.toBase64()!,
            "iv": aesIV.toBase64()!
        ]
        return jsonObject
    }
    
    
    // MARK: - Key Helper Functions
    
    /**
     Generate a cryptographically secure random number from the Security
     framework using Randomization Services.

     - parameters:
        - size: The number of bytes. Also represents the length of the key.
     
     - returns:
        Will return strong random numbers or nil if there was an issue
        with an entropy pool request.
    */
    func generateSecureKey(of size: Int) -> [UInt8]? {
        
        let keyPtr = UnsafeMutableRawPointer.allocate(bytes: size, alignedTo: MemoryLayout<UInt8>.alignment)
        if SecRandomCopyBytes(kSecRandomDefault, size, keyPtr) != errSecSuccess {
            // Something went wrong internally with generating CSPRNG's.
            return nil
        }
        
        let intPtr = keyPtr.bindMemory(to: UInt8.self, capacity: size)
        
        var key = [UInt8]()
        for x in 0..<size {
            key.append(intPtr.advanced(by: x).pointee)
        }
        return key
    }
    enum KeyType {
        case publicKeyType
        case privateKeyType
    }
    /**
     Retrieve the app's public RSA key. This will be generated if necessary
     or found in the app's main bundle if already present. Returns a Data
     object representing the public RSA key derived from a 2048-bit private
     RSA key in DER format.
     */
    var publicKey: Data {
        get {
            // Try to find public key in documents.
            let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let url = dir?.appendingPathComponent("public_rsa_id").appendingPathExtension("der") {
                do {
                    var readIn = try String(contentsOf: url)
                    if let data = readIn.data(using: .ascii) {
                        return data
                    }
                } catch { print("Nope!") }
            }
            
//            // Try to find public key in main bundle.
//            if let path = Bundle.main.path(forResource: "public_rsa_id", ofType: "der") {
//                do {
//                    let content = try String(contentsOfFile: path, encoding: .ascii)
//                    if let data = content.data(using: .ascii) {
//                        return data
//                    }
//                } catch { }
//            }
            // Generate and store key in application bundle if none was found.
            return generateAndStoreKeys(returning: .publicKeyType)
        }
    }
    /**
     Retrieve the app's private RSA key. This will be generated if necessary
     or found in the app's main bundle if already present. Returns a Data
     object representing the private RSA key generated with 2048-bits in
     DER format.
     */
    var privateKey: Data {
        get {
            // Try to find private key in documents.
            let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            if let url = dir?.appendingPathComponent("private_rsa_id").appendingPathExtension("der") {
                do {
                    var readIn = try String(contentsOf: url)
                    if let data = readIn.data(using: .ascii) {
                        return data
                    }
                } catch { print("Nope!") }
            }
            
//            if let path = Bundle.main.path(forResource: "private_rsa_id", ofType: "der") {
//                do {
//                    let content = try String(contentsOfFile: path, encoding: .ascii)
//                    if let data = content.data(using: .ascii) {
//                        return data
//                    }
//                } catch { }
//            }
            
            // Generate and store key in application bundle if none was found.
            return generateAndStoreKeys(returning: .privateKeyType)
        }
    }
    
    /**
     Generates a 2048-bit DER formatted key pair and stores the files to the app
     bundle under the file component 'private_rsa_id.der' and 'public_rsa_id.der'.
     Keys are stored with ASCII encoding.
     
     - parameters:
        - returning: Used to specify the key desired post-generation and storage.
                    Enumerated type of publicKeyType or privateKeyType.
     - returns:
            A Data object is returned which represent the RSA key specified in the
            returning parameter.
     */
    private func generateAndStoreKeys(returning: KeyType) -> Data {
        print("ViewController - Generating keys.")
        // Generate keys with SwCrypt library
        let (privateKeyData, publicKeyData) = try! CC.RSA.generateKeyPair(2048)
        // Store in app bundle
        let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        if let url = dir?.appendingPathComponent("private_rsa_id").appendingPathExtension("der") {
            do {
                try privateKeyData.write(to: url)
            } catch { }
        }
        if let url = dir?.appendingPathComponent("public_rsa_id").appendingPathExtension("der") {
            do {
                try publicKeyData.write(to: url)
            } catch { }
        }
//        let privateKeyURL = Bundle.main.bundleURL.appendingPathComponent("private_rsa_id").appendingPathExtension("der")
//        let publicKeyURL = Bundle.main.bundleURL.appendingPathComponent("public_rsa_id").appendingPathExtension("der")
//
//        do {
//            try String(data: privateKeyData, encoding: .ascii)!.write(to: privateKeyURL, atomically: true, encoding: .ascii)
//            try String(data: publicKeyData, encoding: .ascii)!.write(to: publicKeyURL, atomically: true, encoding: .ascii)
//        } catch { print("Couldn't save the keys to bundle.") }
        // Return requested key type
        if returning == .privateKeyType {
            return privateKeyData
        } else {
            return publicKeyData
        }
    }
}























