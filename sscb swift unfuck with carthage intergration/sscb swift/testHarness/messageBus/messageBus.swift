//
//  messageBus.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/05.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation

enum deliveryType {
    case DIRECT
    case MULTICAST
}


enum messageType : String {
    
    case ADVERTISE = "ADVERTISE"
    case HANDSHAKE_SEND1 = "SEND1"
    case HANDSHAKE_SEND2 = "SEND2"
    case HANDSHAKE_REPLY1 = "REPLY1"
    case HANDSHAKE_REPLY2 = "REPLY2"
    case LOGOUT = "LOGOUT"
    case SAY = "SAY"
    
}

typealias messageBox = [message?]

struct message {
    
    let delType : deliveryType
    let sender : String
    let target : String
    let type : messageType
    let text : String?
    let data : Data?

}

class messageBus {
    
    var data = messageBox()
    
    func send (m: message) -> Bool {
        
        data.append(m)
        return false;
    }
    
    func broacast (m: message) -> Bool {
        
        data.append(m)
        return false;
    }
    
    func read ( me : String ) -> messageBox? {
        
        var mine = messageBox()
        for i in data {
            
            if (i?.delType == deliveryType.MULTICAST || i?.target == me) {
                
                if (i?.sender != me) {
                    mine.append(i)  //
                }
            }
            
        }
        
        if (mine.isEmpty) { return nil }
        
        //clear pipe
        data = messageBox()
        
        return mine;
        
    }
    
}
