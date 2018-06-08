//
//  servus.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/07.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation
import Servus
import Interstellar

var peerExplorerDidSpotPeerObserver = Observable<Peer>()
var peerExplorerDidDeterminePeerObserver = Observable<Peer>()
var peerExplorerDidLosePeerObserver = Observable<Peer>()


class ServusMeshnetProvider {
    
    var explorer: Explorer!
    var servusObserver = Observable<UDPMessage>()
    
    init () {
        
        explorer = Explorer()
        explorer.delegate = self
        explorer.startExploring() // Start announcing this device's presence & reporting discovery of other ones.
        
    }
    
}

extension ServusMeshnetProvider: ExplorerDelegate {
    func explorer(_ explorer: Explorer, didSpotPeer peer: Peer) {
        
        peerExplorerDidSpotPeerObserver.update(peer)
        
        print("Spotted \(peer.identifier). Didn't determine its addresses yet")
    }
    
    func explorer(_ explorer: Explorer, didDeterminePeer peer: Peer) {
        peerExplorerDidDeterminePeerObserver.update(peer);
        print("Determined hostname for \(peer.identifier): \(peer.hostname!)")
    }
    
    func explorer(_ explorer: Explorer, didLosePeer peer: Peer) {
        peerExplorerDidLosePeerObserver.update(peer)
        //hostname is not available
        print("Lost \(peer.identifier) from sight")
    }
}



