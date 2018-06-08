//
//  sercretHandshake.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/05.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation
import Sodium

enum handshakeType {
    
    case CALL
    case RESPONSE
    
}
enum handshakeReplyType : String {
    
    case SEND1 = "send1"
    case SEND2 = "send2"
    case REPLY1 = "reply1"
    case REPLY2 = "reply2"
    case COMPLETED = "completed"
    case ILLEGAL = "illegal packet"
    case TERMINATE = "terminate"
    
    static func allValues() -> [handshakeReplyType] {
        return [.SEND1, .SEND2, .REPLY1, .REPLY2, .TERMINATE ]
    }
    
}

struct handshakeMessage {
    
    let type : handshakeReplyType
    let data : Data
    
}

struct handshakeKeys {
    
    var pairEphPubKey : Data?
    var round2 : Data?
    
    
}


//let caller level take care of net calls
//just return the stuff that we want to send over to the victim

struct hmacMessagePair {
    
    let tag : Data
    let message : Data
    
}

class secretHandshake  {
    
    var name : String
    //var ip : String
    var terminated = false;
    //var hskeys : handshakeKeys  //keys he passed
    var round = 0   //handshake round
    var type : handshakeType?
    var myKeyPair : Box.KeyPair?
    var ephKeys : SsbEpheremalKeySet?
    var targetEphPublicKey : Box.PublicKey?
    
    lazy var _ssbkeys = ssbKeys()
    
    init ( name: String ,type : handshakeType , myk : Box.KeyPair? ) {
        
        self.name = name;
        //self.ip = ip;
        self.type = type    //call response
        //hskeys = handshakeKeys(pairEphPubKey: nil, round2: nil)
        myKeyPair = myk;
        
    }
    
    //returns a string to talk to the recipient
    
    func startHandshaking ( targetPubKey : Box.PublicKey ) -> handshakeMessage? {
        
        //if type != nil { return nil }
        type = handshakeType.CALL
        
        guard let eKeys = _ssbkeys.generateEphemeralScuttlebuttKeys() else { return nil }
        ephKeys = eKeys;
        
        //send eph public key that can be decoded with scbNetworkKey shared key
        //the recipient then knows my temporary public key
        
        //let fap = String(decoding: eKeys.sharedPublic, as: UTF8.self)
        
        
        /*guard let m = _ssbkeys.sign(secretKey: targetPubKey, message: fap ) else {
            return nil
            }*/
        //32 bits of hmac tag header
        //rest is eph pub key
        
        let m = eKeys.hmacHeader + eKeys.pair.publicKey;
        round = round + 1
        
        return handshakeMessage(type: handshakeReplyType.SEND1, data: m)
        
    }
    
    func receiveHandshakeSEND ( data : Data ) -> handshakeMessage? {
        
        //react to send messages
        
        switch (round) {
            
            case 0:
            //i got approached with a handshake. lets see if it matches the scbNetworkSecret
            
                let hmm = splitToHmacAndMessage( m : data )
                guard let networkSecret = _ssbkeys.scbNetworkSecret.data(using: .utf8) else { return nil } //text me
                
            
                if (!_ssbkeys.authVerify(message: hmm.message, secretKey: networkSecret, tag: hmm.tag) ) {
                    //could not verify that this is a ssc message. fuck this shit.
                    return nil
                }
                
                print("received valid eph pub key hmac network secret")
                
                //this means the passed eph public key is validos solidos
                //i got the pairs pub key now
                //hskeys.pairEphPubKey = hmm.message
                
                //create my own eph keys for this session
                guard let eKeys = _ssbkeys.generateEphemeralScuttlebuttKeys() else { return nil }
                ephKeys = eKeys;
                
                targetEphPublicKey = hmm.message
                print("got his targetEphPublicKey now")
                print("replying with my pub eph key hmac network secret")
                
                
                //send the stuff over
                let m = eKeys.hmacHeader + eKeys.pair.publicKey;
                
                round = round + 1
                
                return handshakeMessage(type: handshakeReplyType.REPLY1, data: m)
                
            
            case 1:
            
                //fake
                //we got send2 message signed with my own eph pub key
                let hmm = splitToHmacAndMessage( m : data )
                let secretPub  = ephKeys?.pair.publicKey
                let secretPri = ephKeys?.pair.secretKey
            
                print("received text for handshak, tagged with my eph secretPub")
                
                if (!_ssbkeys.authVerify(message: hmm.message, secretKey: secretPub!, tag: hmm.tag) ) {
                    //could not verify that this is a ssc message. fuck this shit.
                    print ("eph pub key fail")
                }
            
                /*if (!_ssbkeys.authVerify(message: hmm.message, secretKey: secretPri!, tag: hmm.tag) ) {
                    //could not verify that this is a ssc message. fuck this shit.
                    print ("eph pri key fail")
                }*/
                
                let fap = String(decoding: hmm.message, as: UTF8.self)
                print (fap + " from " )
                
                print("sending REPLY2 text to him auth tag my ephKeys?.pair.secretKey that he knows now ")
                
                
                //consider handshake done for my part
                let m = "REPLY2".data(using: .utf8)
                let hmac = _ssbkeys.auth(message: m!, secretKey: secretPub! )
                let mm = hmac+m!;
                
                //hskeys.pairEphPubKey!
                
                round = round + 1
                
                return handshakeMessage(type: handshakeReplyType.REPLY2, data: mm)
            
            
            default: return nil;
            
        }
        
    }
    
    func receiveHandshakeREPLY ( data : Data ) -> handshakeMessage? {
        
        //we got an eph key from target
        switch (round) {
            
        case 1:
            //opponent sent his eph public key
            
            let hmm = splitToHmacAndMessage( m : data )
            guard let networkSecret = _ssbkeys.scbNetworkSecret.data(using: .utf8) else { return nil } //text me
            
            print("received valid eph pub key hmac network secret")
            
            if (!_ssbkeys.authVerify(message: hmm.message, secretKey: networkSecret, tag: hmm.tag) ) {
                //could not verify that this is a ssc message. fuck this shit.
                print("hmac mismatch, bail out ")
                return nil
            }
            
            
            //this means the passed eph public key is validos solidos
            //i got the pairs pub key now
            targetEphPublicKey = hmm.message
            print("got his targetEphPublicKey now")
            //this guy has my eph pb key
            
            //fake the rest of the handshake
            //set baloney string
            
            print("sending send2 text to him auth tag his targetEphPublicKey")
            
            let m = "SEND2".data(using: .utf8)
            let hmac = _ssbkeys.auth(message: m!, secretKey: targetEphPublicKey! )
            let mm = hmac+m!;
            
            
            round = round + 1
            
            return handshakeMessage(type: handshakeReplyType.SEND2, data: mm)
            
            /*
            //create my own eph keys for this session
            guard let eKeys = _ssbkeys.generateEphemeralScuttlebuttKeys() else { return nil }
            ephKeys = eKeys;
            
            //send the stuff over
            let m = eKeys.hmacHeader + eKeys.pair.publicKey;
            
            round = round + 1
            
            return handshakeMessage(type: handshakeReplyType.REPLY1, data: m)
            */
            
            
        case 2:
            
            //COMPLETED
            let hmm = splitToHmacAndMessage( m : data )
            
            //let secretPub  = hskeys.pairEphPubKey
            //let secretPri = hskeys.pairEphPubKey
            print ("receiving last handshake step, tagged with his ephPubKey i know" )
            
            if (!_ssbkeys.authVerify(message: hmm.message, secretKey: targetEphPublicKey! , tag: hmm.tag) ) {
                //could not verify that this is a ssc message. fuck this shit.
                print ("eph pub key fail")
            }
            
            /*if (!_ssbkeys.authVerify(message: hmm.message, secretKey: secretPri!, tag: hmm.tag) ) {
                //could not verify that this is a ssc message. fuck this shit.
                print ("eph pri key fail")
            }*/
            
            let fap = String(decoding: hmm.message, as: UTF8.self)
            print (fap + " from " )
            
            return handshakeMessage(type: handshakeReplyType.COMPLETED, data: hmm.message)
            
            
            return nil;
            
            
        default: return nil;
            
        }
        
        
    }
    
    func clientVerifyAccept () {
        
        
        
        
    }
    
/*exports.clientVerifyAccept = function (state, boxed_okay) {
 assert_length(boxed_okay, 'server_auth', exports.server_auth_length)
 
 var b_alice = shared(curvify_sk(state.local.secretKey), state.remote.kx_pk)
 state.b_alice = b_alice
 state.secret3 = hash(concat([state.app_key, state.secret, state.a_bob, state.b_alice]))
 
 var sig = unbox(boxed_okay, nonce, state.secret3)
 if(!sig) return null
 var signed = concat([state.app_key, state.local.hello, state.shash])
 if(!verify(sig, signed, state.remote.publicKey))
 return null
 return state
 }
    */
    
    func splitToHmacAndMessage ( m : Data ) -> hmacMessagePair {
        
        let hmac = m.subdata(in:  0..<32)
        let mess = m.subdata(in: 32..<m.count  )
        
        return hmacMessagePair(tag: hmac, message: mess)
    }
    
    
}
