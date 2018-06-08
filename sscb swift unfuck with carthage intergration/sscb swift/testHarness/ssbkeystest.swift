//
//  ssbkeystest.swift
//  sscb swift
//
//  Created by sami on 2018/06/04.
//  Copyright © 2018年 pancristal. All rights reserved.
//

import Foundation
import Sodium


extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        
        return String(data: data as Data, encoding: String.Encoding.utf8)
    }
    
    func toBase64() -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}





class SsbKeysTest {
    
    lazy var sodium = Sodium()
    let mssbKeys = ssbKeys();
    
    let _njetwork = networkAdapter(_mb: messageBus())
    let _meshnet = ServusMeshnetProvider()
    
    var uunot = scuttlers(data:[])
    
    func test() {
        
        
        uunot.data.insert(userFrame(name: "Jerry", ip: "home" ,mb: _njetwork), at: 0)
        //uunot.data.insert(userFrame(name: "Mr Kijewski", ip: "Alcohole Galaxy",mb: _njetwork), at: 1)
        //uunot.data.insert(userFrame(name: "Wojciec", ip: "rainbow gathering",mb: _njetwork  ), at: 2)
        
        //give em keys
        for u in uunot.data {
            
            let keys = mssbKeys.generate()
            u?.setMyKeys(keys: keys)
            
        }
        
        //copy public keys
        /*var preuuno : userFrame? = nil
        for u in uunot.data {
            
            if (preuuno == nil ) {
                preuuno = u;
                continue;
            }
            preuuno?.addFriend(friend: friend(name: (u?.data?.name)!,ip: (u?.data?.ip)!, publicKey: u?.data?.mySsbKeys?.publicKey, ephKey: nil, connections: nil))
            
            u?.addFriend(friend: friend(name: (preuuno?.data?.name)!,ip: (preuuno?.data?.ip)!, publicKey: preuuno?.data?.mySsbKeys?.publicKey, ephKey: nil, connections: nil))
            
            preuuno = u
            
        }*/
        
        
        
        
        let tum = 1;
            //user(name: "jerry", ip: "0", mySsbKeys: nil, knownUsers: nil), at: 0)
        
        //uunot.data[1]?.handshakeFriend(name: (uunot.data[2]?.data?.name)!)
        
        //Swift >=3 selector syntax
        var timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        
        
        return;
        
        uunot.data[1]?.advertise()
        
        //react
        uunot.data[2]?.listen();
        
        //woj listens for hanshake reply
        uunot.data[1]?.listen();
        
        uunot.data[2]?.listen();
        
        uunot.data[1]?.listen();
        
        uunot.data[2]?.listen();
        
        uunot.data[1]?.listen();
        
        //var myUser = user(mySsbKeys: nil)
        
        //https://www.objc.io/blog/2018/02/13/string-to-data-and-back/
        guard let message1: Data = "Café perse".data(using: .utf8) else { return }
        guard let message2: Data = "Café lobotomia".data(using: .utf8) else { return }
        guard let message3: Data = "Café vomitoland".data(using: .utf8) else { return }
        
        
        
        //if let ko = ssbKeys
    
        
        
        let secretkey = sodium.secretStream.xchacha20poly1305.key()
    
        /* stream encryption */
    
        let stream_enc = sodium.secretStream.xchacha20poly1305.initPush(secretKey: secretkey!)!
        let header = stream_enc.header()
        let encrypted1 = stream_enc.push(message: message1)!
        let encrypted2 = stream_enc.push(message: message2)!
        let encrypted3 = stream_enc.push(message: message3, tag: .FINAL)!
        
        let aliceKeyPair = sodium.box.keyPair()!
        let bobKeyPair = sodium.box.keyPair()!
        
        let alpubes = aliceKeyPair.publicKey.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        let lam = "@"+alpubes+"=ed25519";
        
        print(alpubes) // Zm9v
        
        
        //let alPub =
        
        let encryptedMessageFromAliceToBob: Data =
            sodium.box.seal(message: message1,
                            recipientPublicKey: bobKeyPair.publicKey,
                            senderSecretKey: aliceKeyPair.secretKey)!
        
        let fap = String(decoding: encryptedMessageFromAliceToBob, as: UTF8.self)
        print(fap)
        
        let messageVerifiedAndDecryptedByBob =
            sodium.box.open(nonceAndAuthenticatedCipherText: encryptedMessageFromAliceToBob,
                            senderPublicKey: aliceKeyPair.publicKey,
                            recipientSecretKey: bobKeyPair.secretKey)
        
        let fup = String(decoding: messageVerifiedAndDecryptedByBob!, as: UTF8.self)
        print (fup)
        
        let didl = 1;
    }
    
    // must be internal or public.
    @objc func update() {
        // Something cool
        uunot.data[1]?.advertise()
        
    }
    
}
