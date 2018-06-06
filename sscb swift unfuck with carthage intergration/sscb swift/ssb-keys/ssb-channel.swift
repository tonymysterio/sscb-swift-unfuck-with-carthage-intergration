//
//  ssb-channel.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/06.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation
import Sodium
class ssbChannel {
    
    lazy var _ssbkeys = ssbKeys()
    var hisPublicKey : Box.PublicKey
    var myPrivateKey : Box.SecretKey
    
    init( _hisPublicKey : Box.PublicKey , _myPrivateKey : Box.PublicKey ){
        
        hisPublicKey = _hisPublicKey
        myPrivateKey = _myPrivateKey
        
    }
    
    func listen ( message : Data ) -> Data? {
        
        //decrypt and check
        return _ssbkeys.open(d: message, senderPublicKey: hisPublicKey, recipientSecretKey: myPrivateKey)
        
    }
    
    func say ( message : Data ) -> Data? {
        
        //encrypt data with his public key
        //let lower layer take care of message parsing
        print ("direct encrypted say encoded with his ephPublicKey")
        
        guard let m = _ssbkeys.seal(message: message, senderSecretKey: myPrivateKey , recipientPublicKey: hisPublicKey) else {
            
            return nil;
        }
        
        return m
        
    }
    
    
}
