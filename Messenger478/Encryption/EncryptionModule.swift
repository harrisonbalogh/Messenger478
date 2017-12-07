//
//  EncryptionModule.swift
//  Messenger478
//
//  Created by Harrison Balogh on 12/5/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

import Foundation

class EncryptionModule {
    
    // MARK: - Export Public Key
    
    /**
     Creates an exportable version of user's public key, effectively converting
     a public RSA SecKey object into a String unless an error occurs.
     
     - returns: String object converted from CFData in PCKS#1 format which was
     converted from a public 2048-bit RSA key or nil if an error occurs.
    */
    static func exportPublicKey() -> Data? {
        guard let data = SecKeyCopyExternalRepresentation(publicKeyRSA, nil) else {return nil}
        return data as NSData as Data
    }
    
    // MARK: - Security Transforms
    
    /**
     Encrypts the provided CFData using AES-256 bit encryption in
     GCM mode. The AES key itself is generated and encrypted by the
     RSA public key and then packaged together with the digest data.
     There must be a valid public RSA key already received from the
     recepient or this will return nil.
     
     - parameters:
        - data: The data to be encrypted as a CFData object.
     
     - returns:
     Digest data encrypted from the provided text or nil if
     an error occurred.
     */
    static func encrypt(text: String) -> Data? {
        let data = text.data(using: .utf8)! as NSData as CFData
        let encryptionAlgorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256AESGCM
        guard let publicKey = MessengerConnection.recipeintPublicKeyRSA else {return nil}
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, encryptionAlgorithm) else {return nil}
        guard let cipherText = SecKeyCreateEncryptedData(publicKey, encryptionAlgorithm, data, nil) else {return nil}
        return cipherText as NSData as Data
    }
    
    /**
     Decrypts the provided CFData that was encrypted with AES-256
     it encrpytion in GCM mode. Requires the private key from the
     public key used in encryption or returns nil.
     
     - parameters:
        - data: The data to be decrypted as a CFData object.
     
     - returns:
     Plain text data from the encrypted data.
    */
    static func decrypt(data: Data) -> String? {
        let conv = data as NSData as CFData
        let decryptionAlgorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256AESGCM
        guard SecKeyIsAlgorithmSupported(privateKeyRSA, .decrypt, decryptionAlgorithm) else {return nil}
        guard let plainText = SecKeyCreateDecryptedData(privateKeyRSA, decryptionAlgorithm, conv, nil) else {return nil}
        return String(data: (plainText as NSData as Data), encoding: .utf8)
    }
    
    /**
     Produce an authentication signature from the provided digest. Uses RSA_SHA256 signing algorithm.
     
     - parameters:
        - digest: The RSA encrypted form of a message.
     
     - returns:
     CFData object representing a digital signature from the provided digest, or nil
     if an error occurred.
    */
    static func signature(for digest: CFData) -> CFData? {
        let signAlgorithm: SecKeyAlgorithm = .rsaSignatureDigestPKCS1v15SHA256
        guard SecKeyIsAlgorithmSupported(privateKeyRSA, .sign, signAlgorithm) else { return nil }
        guard let signature = SecKeyCreateSignature(privateKeyRSA, signAlgorithm, digest, nil) else { return nil }
        return signature
    }
    
    // MARK: - RSA Keys
    
    private static let TAG_PRIVATE = "com.messenger478.tagPrivate"
    private static let TAG_PUBLIC  = "com.messenger478.tagPublic"
    
    private static var cached_publicKeyRSA: SecKey?
    private static var publicKeyRSA: SecKey {
        get {
            if cached_publicKeyRSA == nil {
                GenerateKeyPairRSA()
            }
            return cached_publicKeyRSA!
        }
    }
    private static var cached_privateKeyRSA: SecKey?
    private static var privateKeyRSA: SecKey {
        get {
            if cached_privateKeyRSA == nil {
                GenerateKeyPairRSA()
            }
            return cached_privateKeyRSA!
        }
    }
    
    /**
     Fills the publicKeyRSA and privateKeyRSA caches with a 2048-bit RSA key pair.
    */
    private static func GenerateKeyPairRSA() {
        let privateKeyAttr: [NSString: Any] = [
            kSecAttrIsPermanent: false,
            kSecAttrApplicationTag: TAG_PRIVATE.data(using: .utf8)!
        ]
        let publicKeyAttr: [NSString: Any] = [
            kSecAttrIsPermanent: false,
            kSecAttrApplicationTag: TAG_PUBLIC.data(using: .utf8)!
        ]
        let parameters: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: privateKeyAttr,
            kSecPublicKeyAttrs as String: publicKeyAttr
        ]
        
        let status = SecKeyGeneratePair(parameters as CFDictionary, &cached_publicKeyRSA, &cached_privateKeyRSA)
        
        if status != noErr {
            print("SecKeyGeneratePair Error! \(status.description)")
            return
        }
    }
}
