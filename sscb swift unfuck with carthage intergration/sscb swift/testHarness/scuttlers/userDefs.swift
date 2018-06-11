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

struct friend : Hashable,Equatable {
    
    var name :String
    var ip : String
    var publicKey : Box.PublicKey?
    var ephKey : Data?
    var connections = ssbConnections()
    
    
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
