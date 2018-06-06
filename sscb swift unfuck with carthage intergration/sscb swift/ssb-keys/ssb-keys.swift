//
//  ssb-keys.swift
//  sscb swift
//
//  Created by sami on 2018/06/04.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

//https://code.tutsplus.com/tutorials/swift-and-regular-expressions-swift--cms-26626
//http://git.scuttlebot.io/%25133ulDgs%2FoC1DXjoK04vDFy6DgVBB%2FZok15YJmuhD5Q%3D.sha256/blob/fd953a1e72b4b16e6e5a74bcf2f893dbf1407ce4/sbotc.c


import Foundation
import Sodium
import Sodium.Swift
import libsodium
//var sodium     = require('chloride')
//var pb         = require('private-box')
//var u          = require('./util')

//var isBuffer = Buffer.isBuffer

//UTILS

//function clone (obj) {  clone js object

//var hmac = sodium.crypto_auth

//exports.hash = u.hash
//exports.getTag = u.getTag

//function isObject (o) {
//function isFunction (f) {
//function isString(s) {

/*public struct SodiumKeyPair {
    
    public let publicKey: Sodium.Box.PublicKey
    
    public let secretKey: Sodium.Box.SecretKey
    
    public init(publicKey: Sodium.Box.PublicKey, secretKey: Sodium.Box.SecretKey)
}*/

/*
 let sodium = Sodium()
 let data1 = sodium.utils.hex2bin("deadbeef")
 let data2 = sodium.utils.hex2bin("de:ad be:ef", ignore: " :")
 Constant-time base64 encoding
 let sodium = Sodium()
 let b64 = sodium.utils.bin2base64("data".bytes)!
 let b64_2 = sodium.utils.bin2base64("data".bytes, variant: .URLSAFE_NO_PADDING)!
 Base64 decoding
 let data1 = sodium.utils.base642bin(b64)
 let data2 = sodium.utils.base642bin(b64, ignore: " \n")
 let data3 = sodium.utils.base642bin(b64_2, variant: .URLSAFE_NO_PADDING, ignore: " \n")
 */


enum ssbCurves {
    
    case ed25519
    
}

struct SsbEpheremalKeySet {
    
    let pair : Box.KeyPair
    //let sharedPublic : Box.PublicKey     //openable with ssbc network key
    let hmacHeader : Data
}

struct SsbKeyPair : Hashable {
    
    let publicKey : Data
    let privateKey : Data
    
    var hashValue: Int {
        return publicKey.hashValue ^ publicKey.hashValue &* 16777619
    }
    
    
}


struct SsbKeys {
    
    let pairs : Set<SsbKeyPair>?
    let curve : ssbCurves = ssbCurves.ed25519
    
}



class ssbKeys {
    
    lazy var sodium = Sodium()
    let scbNetworkSecret = "12345678901234567890123456789012"
    
    //minimal implementation
    
//var curves = {}
//curves.ed25519 = require('./sodium')
    func generate () -> Box.KeyPair? {
        
        //let secretkey = sodium.secretStream.xchacha20poly1305.key()
        return sodium.box.keyPair()!    //original returns json
        
    }
    
    func sign (secretKey : Box.PublicKey , message : String ) -> Data? {
        
        //return signature
        
        guard let m: Data = message.data(using: .utf8) else { return nil }
        
        //keep it as data because we want to send it over udp,tcpip
        let signature: Data = sodium.secretBox.seal(message: m, secretKey: secretKey)!
        /*if let decrypted = sodium.secretBox.open(nonceAndAuthenticatedCipherText: encrypted, secretKey: secretKey) {
            // authenticator is valid, decrypted contains the original message
        }*/
        
        return signature
        
    }
    
    func open ( d : Data , senderPublicKey : Box.PublicKey, recipientSecretKey : Box.SecretKey ) -> Data? {
        
        guard let decryptedMessage =
            sodium.box.open(nonceAndAuthenticatedCipherText: d,
                            senderPublicKey: senderPublicKey,
                            recipientSecretKey: recipientSecretKey) else { return nil }
        
        return decryptedMessage //this is total garbage if the decrytion dndt work
        
    }
    
    func verify ( message : Data, secretKey : Box.PublicKey ,signature : Data ) -> Bool {
        
        //let signature = sodium.sign.signature(message: message, secretKey: signature.secretKey)!
        if sodium.sign.verify(message: message,
                              publicKey: secretKey,
                              signature: signature) {
            // signature is valid
            return true;
        }
        
        return false;
    }

    func box () {
        //multiple recipients with private-box
        
    }

    func unbox() {
        //unboxing
        
    }
    
    func seal ( message : Data, senderSecretKey : Box.SecretKey , recipientPublicKey : Box.PublicKey ) ->Data? {
        
        return sodium.box.seal(message: message,
                               recipientPublicKey: recipientPublicKey,
                               senderSecretKey: senderSecretKey)!
        
        
    }
    
    func generateEphemeralScuttlebuttKeys () -> SsbEpheremalKeySet?  {
        
        guard let keys = generate() else { return nil }
        let networkSecret = scbNetworkSecret.data(using: .utf8) as! Data //else { return nil } //text me
        
        //let networkSecretCodedPubkey: Data = sodium.secretBox.seal(message: keys.publicKey, secretKey: networkSecret)!
        //let hmacHeader = sodium.sign.signature(message: keys.publicKey, secretKey: networkSecret)!
        
        //send a temporyr public key. the recipient can check if its valid witihin scb network
        let hmacHeader = sodium.auth.tag(message: keys.publicKey, secretKey: networkSecret)!
        
        //tag is first 32bits, followed by the eph pub key
        
        return SsbEpheremalKeySet(pair: keys, hmacHeader : hmacHeader)
        
    }
    
    func auth ( message : Data, secretKey : Box.PublicKey  ) -> Data {
        
        //call a
        
        return sodium.auth.tag(message: message, secretKey: secretKey)!
        
        
    }
    
    func authVerify ( message : Data, secretKey : Box.PublicKey , tag : Data ) -> Bool {
        
        return sodium.auth.verify(message: message, secretKey: secretKey, tag: tag)
    }
    
}
