//
//  ssbConnections.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/11.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation

enum ssbConnectionTypes {
    case INCOMING
    case OUTGOING
    case PUBLIC_BROADCAST }

class ssbConnections {
    
    //var data = [ssbConnection?]()
    var incoming : ssbConnection?
    var outgoing : ssbConnection?
    var publicBroadcast : ssbConnection?
    
    func add ( type : ssbConnectionTypes , name:String, ip: String) -> ssbConnection? {
        
        switch (type) {
            
        case  ssbConnectionTypes.INCOMING :
            
            if let c = incoming { return c }
            incoming = ssbConnection(name: name, ip: ip, inbound: true, handshaked: false, terminated: false, handshake: nil, channel: nil)
            return incoming
            
        case  ssbConnectionTypes.OUTGOING :
            
            if let c = outgoing { return c }
            incoming = ssbConnection(name: name, ip: ip, inbound: false, handshaked: false, terminated: false, handshake: nil, channel: nil)
            return incoming
            
        case  ssbConnectionTypes.PUBLIC_BROADCAST :
            
            //pushing public messages for everybody who has my connection key
            
            if let c = publicBroadcast { return c }
            publicBroadcast = ssbConnection(name: name, ip: ip, inbound: false, handshaked: false, terminated: false, handshake: nil, channel: nil)
            return publicBroadcast
            
            
            
        default :
            
            return nil;
        }
        
        
        
    }
    
    
    /*func add (name:String, ip: String) -> ssbConnection? {
        
        for f in data {
            
            if (f?.name == name) { return nil }
            
        }
        
        let nc = ssbConnection(name: name, ip: ip, inbound: false, handshaked: false, terminated: false, handshake: nil, channel: nil)
        data.append(nc)
        
        return nc
    }*/
    
}
