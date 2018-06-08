//
//  userHarness.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/05.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation
import Sodium


class userFrame {
    
    var data : user?
    lazy var _ssbKz = ssbKeys()
    
    weak var mNet : networkAdapter?
    //HWnetworkAdapterUDPReceivedObserver
    
    
    init( name : String, ip : String , mb : networkAdapter) {
        
        var userx = user(name: name, ip: ip, mySsbKeys: nil ,friends : [friend?]())
        
        //make and copy keys
        let ssbKeys = _ssbKz.generate()
        userx.mySsbKeys = ssbKeys
        
        self.data = userx;
        self.mNet = mb;
        
        HWnetworkAdapterUDPReceivedObserver.subscribe{ udpMessage in
            
            /*if let mud = mNet.receiveUDP( m : UDPMessage ) {
                
                processMessage(m: m)    // just process this
            } */
            //var m = UDPMessage(data: ca, ip: remoteip, port: self.broadcastPort)
            
            //stuff that comes for built in test
            let senderName = udpMessage.ip;
            let senderIp = udpMessage.ip;
            
            //
            guard let mess = self.mNet?.hwb?.convertIncomingToTypedMessage(delType: deliveryType.DIRECT, dat: udpMessage.data, ip: senderIp) else {
                return
            }
            //shoehorn into a message
            self.processMessage(m: mess)
            
        }
        
        //servus stuff
        peerExplorerDidSpotPeerObserver.subscribe { peer in
            
            //this might alert the users UI
            //maybe no need
            
        }
        
        
        peerExplorerDidDeterminePeerObserver.subscribe { peer in
            
            //inform user. might end up into a big list
            //some of these peers might not be valid data providers
            
            //identifier
            //hostname
            
            //search for peerDataRequester for this peer
            self.advertise()
            /*DispatchQueue.global(qos: .utility).async {
                
                
                self.pollNewPeerForData(peer: peer)
                
            }*/
        }
        
        peerExplorerDidLosePeerObserver.subscribe() { peer in
            
            //var id = peer.identifier    //host cannot be seen now
            //DispatchQueue.main.async {
            /*DispatchQueue.global(qos: .utility).async {
                
                
                self.peerExplorerDidLosePeer(peer: peer)
            }*/
            
        }
        
    
    }
    
    func setMyKeys (keys : Box.KeyPair? ) {
        
        //keep the cyanide calls outside
        data?.mySsbKeys = keys
        
    }
    
    func addFriend ( friend : friend ) -> friend? {
        
        //we know of his public key
        //guard let co = data?.knownUsers?.count else {
        data?.friends.append(friend)
        
        //}
        return friend
        
    }
    
    func findFriend ( name : String  ) -> friend? {
        
        guard let fr = data?.friends else { return nil }
        for x in fr {
            
            if (x?.name == name) { return x; }
            
        }
        
        return nil
        
    }
    
    func updateFriend ( f: friend ) -> Bool {
        
        guard let fr = data?.friends else { return false }
        var c = 0;
        for x in fr {
            
            if (x?.name == f.name) {
                
                data?.friends[c] = f;
                return true;
            }
            c = c + 1;
        }
        
        return false;
        
    }
    
    func sayHello () {
        
        
        
    }
    
    func listen () {
        //mNet?.send(sender: self.data?.name!, to: friendo.name, ip: friendo.ip, mess:
        
        guard let mes = mNet?.read(name: self.data!.name) else { return }
        for f in mes {
            processMessage(m: f!)
        }
        
    }
    
    
    
    
    func handshakeFriend ( name : String , ip : String ) {
        
        guard var friendo = findFriend(name: name) else { return }
        let hs = secretHandshake(name: friendo.name, type: handshakeType.CALL, myk: nil )
        
        let conn = ssbConnection(name: name, ip : ip ,inbound: false, handshaked: false, terminated: false, handshake: hs, channel : nil )
        
        //friendo.connections.add(name: name, ip: ip)
        
        friendo.connections = conn; //only one for now
        
        
        
        if let seMes = friendo.connections?.handshake?.startHandshaking(targetPubKey: friendo.publicKey!) {
            
            updateFriend(f:friendo)
            
            //not a null, lets handshake
            mNet?.send(sender: (self.data?.name)!, to: friendo.name, ip: friendo.ip, mess: message(delType: deliveryType.DIRECT, fromIp : self.data!.ip, sender: self.data!.name, target: friendo.name, type: messageType.HANDSHAKE_SEND1, text: "handshaka 1", data: seMes.data))
            
        }
        
    }
    
    func setKnownKeyPai (keys : Box.KeyPair? ) {
        
        //data?.knowSsbPublicKeys?.pairs?.insert(keys)
        
    }
    
    func beginHandshake ( u : userFrame) {
        
        //guard let pubKey = u.data.mySsbKeys?.publicKey else { return nil }
        
    }
    
    func completeHandshake ( f : friend ) {
        
        if let name = data?.name {
            print ( name + " COMPLETED handshake with " + f.name+"@"+f.ip )
        }
        
        
        //f.connections?.handshaked = true;
        updateFriend(f:f)
        
        
        
        let m = "hello " + f.name + "!"
        
        say(name: f.name, _message: m.data(using: .utf8)!)
        
    }
    
    func say ( name : String , _message : Data ) {
        
        guard var friendo = findFriend(name: name) else { return }
        
        if let encryptedMessage = friendo.connections?.channel?.say(message: _message) {
            
            mNet?.send(sender: (self.data?.name)!, to: friendo.name, ip: friendo.ip, mess: message(delType: deliveryType.DIRECT, fromIp :(self.data?.ip)!,  sender: self.data!.name, target: friendo.name, type: messageType.SAY, text: "", data: encryptedMessage))
            
        }
        
    }
    
    func advertise () {
        
        //THIS is going to so bite me on the back
        let m = message(delType: deliveryType.MULTICAST, fromIp: (self.data?.name)!, sender: (self.data?.name)!, target: "", type: messageType.ADVERTISE, text: (self.data?.ip)!, data: self.data?.mySsbKeys?.publicKey)    //send pub key to everyboody
        
        print ("advertising with broadcast")
        
        mNet?.broadcast(mess: m)
        
    }
    
    //nasty stuff follows
    
    func processMessage ( m: message ) {
        
        if let n = self.data?.name {
            
            print (n + " received " + m.type.rawValue + " from " + m.sender )
        }
        
        switch m.type {
            
        case messageType.HANDSHAKE_SEND1 :
            
            var friendo = findFriend(name: m.sender)
            if friendo == nil {
                
                //return
                //add a friend and we dont know his key yet
                print ("added a new friend whos trying to handshake "+m.sender)
                friendo = addFriend(friend: friend(name: m.sender, ip: m.text!, publicKey: m.data, ephKey: nil, connections: nil))
                
            }
            
            let hs = secretHandshake(name: friendo!.name, type: handshakeType.RESPONSE, myk: nil )
            let conn = ssbConnection(name: m.sender, ip: m.fromIp, inbound: true, handshaked: false, terminated: false, handshake: hs , channel : nil )
            friendo!.connections = conn; //only one for now
            
            updateFriend(f:friendo!)
            
            if let seMes = friendo!.connections?.handshake?.receiveHandshakeSEND(data: m.data as! Data) {
                
                mNet?.send(sender: (self.data?.name)!, to: friendo!.name, ip: friendo!.ip, mess: message(delType: deliveryType.DIRECT, fromIp: (self.data?.ip)!, sender: self.data!.name, target: m.sender, type: messageType.HANDSHAKE_REPLY1, text: "shake reply 1", data: seMes.data))
                
            }
            
        case messageType.HANDSHAKE_REPLY1 :
            guard var friendo = findFriend(name: m.sender) else {
                
                return
                
            }
            
            //need a handshake obj for our target
            
            //let hs = secretHandshake(name: friendo.name, type: handshakeType.CALL, myk: nil )
            //let conn = ssbConnection(inbound: false, handshaked: false, terminated: false, handshake: hs , channel : nil)
            //friendo.connections = conn; //only one for now
            let conn = friendo.connections;
            
            if let seMes = conn?.handshake?.receiveHandshakeREPLY(data: m.data as! Data) {
                
                updateFriend(f:friendo)
                mNet?.send(sender: (self.data?.name)!, to: friendo.name, ip: friendo.ip, mess: message(delType: deliveryType.DIRECT , fromIp: (self.data?.name)!, sender: self.data!.name, target: m.sender, type: messageType.HANDSHAKE_SEND2, text: "shake reply 2", data: seMes.data))
                
            }
            
        case messageType.HANDSHAKE_SEND2 :
            
            //in real life this calcs more keys
            //remember to update frendo
            
            guard var friendo = findFriend(name: m.sender) else { return }
            
            if let seMes = friendo.connections?.handshake?.receiveHandshakeSEND(data: m.data as! Data) {
                
                mNet?.send(sender: (self.data?.name)!, to: friendo.name, ip: friendo.ip, mess: message(delType: deliveryType.DIRECT, fromIp: (self.data?.name)!, sender: self.data!.name, target: m.sender, type: messageType.HANDSHAKE_REPLY2, text: "shake reply 2", data: seMes.data))
                
                //THIS IS A SILLY IDEA. hack for now
                let hpke = friendo.connections?.handshake?.targetEphPublicKey
                let mske = friendo.connections?.handshake?.ephKeys?.pair.secretKey
                
                friendo.connections?.handshaked = true;
                friendo.connections?.channel = ssbChannel(_hisPublicKey: hpke!, _myPrivateKey: mske!)
                
                //get rid of the handshake
                completeHandshake(f: friendo)
                
                
                
            }
            
        case messageType.HANDSHAKE_REPLY2 :
            
            guard var friendo = findFriend(name: m.sender) else {
                
                return
                
            }
            
            guard var conn = friendo.connections else { return }
            
            //need a handshake obj for our target
            
            let hpke = friendo.connections?.handshake?.targetEphPublicKey
            let mske = friendo.connections?.handshake?.ephKeys?.pair.secretKey
            
            
            if let seMes = conn.handshake?.receiveHandshakeREPLY(data: m.data as! Data) {
                
                //ok im happy
                
                friendo.connections?.handshaked = true;
                
                
                friendo.connections?.channel = ssbChannel(_hisPublicKey: hpke!, _myPrivateKey: mske!)
                
                //get rid of the handshake
                completeHandshake(f: friendo)
                
                
                
            }
            
        case messageType.SAY :
            
            //got a message
            guard var friendo = findFriend(name: m.sender) else {
                
                return
                
            }   //from blocked user. if user is deleted = block!
            
            //if i dont have a channel yet the handshake is not complete
            
            
            if let mdat = friendo.connections?.channel?.listen(message: m.data!) {
                
                let fup = String(decoding: mdat, as: UTF8.self)
                
                let m = "encrypted message from "+friendo.name+"@"+friendo.ip+" : "+fup
                print(m)
            }
            
            
        case messageType.ADVERTISE :
            
            //somebody is advertizing
            if let friendo = findFriend(name: m.sender) {
                
                if let fc = friendo.connections {
                    
                    
                    return;
                }
                
                    
            handshakeFriend(name: friendo.name ,ip: friendo.ip )
                
                return;
            }
            
            //TODO verify the passed pub key
            
            //add this exciting new acquintance immediately and start handshaking, baby
            if let friendo = addFriend(friend: friend(name: m.sender, ip: m.text!, publicKey: m.data, ephKey: nil, connections: nil)) {
                
                handshakeFriend(name: friendo.name , ip : friendo.ip )
                
            }
            
            
            return;
            
        default:
            return
        }
        
        
    }   //end process messages
    
}
