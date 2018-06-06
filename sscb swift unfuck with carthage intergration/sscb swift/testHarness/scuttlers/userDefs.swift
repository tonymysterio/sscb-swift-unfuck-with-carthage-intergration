//
//  userDefs.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/06.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation
import Sodium

struct scuttlers  {
    var data : [userFrame?]
    
    
    
}


struct ssbConnection {
    
    var name : String
    var ip : String
    var inbound = false;
    var handshaked = false;
    var terminated = false;
    //var keys : handshakeKeys
    var handshake : secretHandshake? = nil  //del handshake after done
    var channel : ssbChannel?
    
}

class ssbConnections {
    
    var data = [ssbConnection?]()
    
    func add (name:String, ip: String) -> ssbConnection? {
        
        for f in data {
            
            if (f?.name == name) { return nil }
            
        }
    
        let nc = ssbConnection(name: name, ip: ip, inbound: false, handshaked: false, terminated: false, handshake: nil, channel: nil)
        data.append(nc)
        
        return nc
    }
    
}

struct friend : Hashable,Equatable {
    
    var name :String
    var ip : String
    var publicKey : Box.PublicKey?
    var ephKey : Data?
    var connections : ssbConnection? //ssbConnections();
    
    var hashValue: Int {
        return name.hashValue ^ ip.hashValue &* 16777619
    }
    
    static func ==(lhs: friend, rhs: friend) -> Bool {
        let areEqual = lhs.name == rhs.name &&
            lhs.ip == rhs.ip
        
        return areEqual
    }
    
}

struct user : Hashable,Equatable {
    
    var name :String
    var ip : String
    var mySsbKeys : Box.KeyPair?
    var friends = [friend?]()
    
    var hashValue: Int {
        return name.hashValue ^ ip.hashValue &* 16777619
    }
    
    static func ==(lhs: user, rhs: user) -> Bool {
        let areEqual = lhs.name == rhs.name &&
            lhs.ip == rhs.ip
        
        return areEqual
    }
}
