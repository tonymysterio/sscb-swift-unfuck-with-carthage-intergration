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
    
    init (_mb : messageBus) {
        
        mb = _mb
        
    }
    
    func read (name: String) -> messageBox? {
        
        return mb?.read(me: name)
        
    }
    
    func send (sender : String, to : String, ip : String , mess : message) {
        
        mb?.send(m: mess)
        
    }
    
    func broadcast ( mess : message ) {
        
        mb?.broacast(m: mess)
        
    }
}
