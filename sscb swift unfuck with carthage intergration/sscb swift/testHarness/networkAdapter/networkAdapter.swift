//
//  networkAdapter.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/06.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation

struct rawNetworkMessage {

    let name : String
    let ip : String
    let data : message

}

class networkAdapter {
    
    var mb : messageBus?
    var hwb : HWnetworkAdapter?
    var outgoingSink = overflowableSink(maxItems: 10,maxItemsPerSource: 3)
    var outgoingSinkSending = false;
    
    init (_mb : messageBus) {
        
        mb = _mb
        hwb = HWnetworkAdapter()
    }
    
    func debuMess ( _ m: String) {
        
        print(m)
        hwb?.debuMess(m)
        
    }
    
    func read (name: String) -> messageBox? {
        
        
        
        return mb?.read(me: name)
        
    }
    
    //just send data to ip
    func rawSend (ip : String ,sdata : Data ){
     
        let r = outgoingSink._push(ip, sdata)
        if !outgoingSinkSending {
            
            if let m = outgoingSink._pull(_maxBytes: networkSpeed._2g_slow.rawValue) {
                
                outgoingSinkSending = true;
                //dangerous approach
                
                for f in m {
                    
                    hwb?.rawSend(ip: ip, sdata: sdata)
                    
                }
                
                outgoingSinkSending = false;
            }
            
        }
        
        
        //hwb?.rawSend(ip: ip, sdata: sdata)
    
    }
    
    func send (sender : String, to : String, ip : String , mess : message) {
        
        hwb?.send(sender: sender, to: to, ip: ip, mess: mess)
        //mb?.send(m: mess)
        
    }
    
    func broadcast ( mess : message ) {
        
        hwb?.broadcast(mess: mess)
        //mb?.broacast(m: mess)
        
    }
    
    //hard net
    func receiveUDP ( m : UDPMessage ) -> message? {
        
        //silly to parse this here
        
        //parse this to readablos
        let w = message(delType: deliveryType.DIRECT, fromIp: m.ip, sender: m.ip, target: "", type: messageType.ADVERTISE, text: "", data: m.data)
        return w;
        
    }
    
}
