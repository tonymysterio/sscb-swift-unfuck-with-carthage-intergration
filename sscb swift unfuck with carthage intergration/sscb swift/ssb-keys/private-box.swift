//
//  private-box.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/04.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation
import Sodium

class PrivateBox {
    
    lazy var sodium = Sodium();
    let DEFAULT_MAX = 7
    
    func randombytes(n : Int ) -> Data? {
        
        return sodium.randomBytes.buf(length: n)
        
        //var b = new Buffer(n)
        //sodium.randombytes(b)
        //return b
    }
    
    
    
    func setMax (m1 : Int ) -> Int? {
        //let m1 = m || DEFAULT_MAX
        if (m1 < 1 || m1 > 255) {
            return nil
        }
        
        return m1
    }
    
    func multibox (msg : String , recipients : [Box.PublicKey] , max : Int) -> Data? {
        
        //receive and return json encoded strings
        
        guard let max = setMax(m1: max) else { return nil }
        
        if ( recipients.count > max) {
    
            return nil
        
        }
        
        var nonce = randombytes(n: 24)
        var key = randombytes(n: 32)
        let onetime = sodium.box.keyPair()!
        
        /*
        var _key : Data = (recipients.count & max)
        
        _key =+
        var _key = concat([new Buffer([recipients.length & max]), key])
    return concat([
    nonce,
    onetime.publicKey,
    concat(recipients.map(function (r_pk, i) {
    return secretbox(_key, nonce, scalarmult(onetime.secretKey, r_pk))
    })),
    secretbox(msg, nonce, key)
    ])
    }
    */
        return nil
        
    }
    
}
