//
//  userHarness.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/05.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation
import Sodium
import Servus



class userFrame {
    
    var data : user?
    lazy var _ssbKz = ssbKeys()
    
    weak var mNet : networkAdapter?
    //let serialQueue = DispatchQueue(label: "messageAppendQueue")
    
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
                
                
                self.mNet?.debuMess("fucked string from "+senderName+"@"+senderIp);
                return
            }
            //shoehorn into a message
            
            //self.serialQueue.sync {
                
               self.processMessage(m: mess)
                
            //}
            
            
            
            
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
            //self.serialQueue.sync {
                self.advertiseToMeshPeer(peer: peer)
            //}
            /*DispatchQueue.global(qos: .utility).async {
                
                
                self.pollNewPeerForData(peer: peer)
                
            }*/
        }
        
        peerExplorerDidLosePeerObserver.subscribe() { peer in
            
            //self.serialQueue.sync {
                self.flushFriends()
            //}
            //self.advertiseToMeshPeer(peer: peer)
            
            //var id = peer.identifier    //host cannot be seen now
            //DispatchQueue.main.async {
            /*DispatchQueue.global(qos: .utility).async {
                
                
                self.peerExplorerDidLosePeer(peer: peer)
            }*/
            
        }
        
        appTerminate.subscribe() { tit in
            
            //send a goodbye messages
            if tit {
            self._teardown();
            } else {
                self._wakeup();
                
            }
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
    
    func findFriendByIp ( ip : String) -> friend? {
        
        guard let fr = data?.friends else { return nil }
        for x in fr {
            
            if (x?.ip == ip) { return x; }
            
        }
        
        return nil
        
    }
    
    
    func pollFriends () {
    
        guard let fr = data?.friends else { return }
    
        
    
        
    
        for x in fr {
    
            //if let encryptedMessage = x?.connections?.channel?.say(message: _message) {
            
                if let na = x?.name {
                    
                    let blabla = "HULLO to "+na+" from "+(self.data?.name)!+"@"+(self.data?.ip)!
                    
                    guard let _message: Data = blabla.data(using: .utf8) else { return }
                    
                    //mNet?.send(sender: (self.data?.name)!, to: x.name, ip: x.ip, mess: message(delType: deliveryType.DIRECT, fromIp :(self.data?.ip)!,  sender: self.data!.name, target: x.name, type: messageType.SAY, text: x.name, data: encryptedMessage))
                    
                    mNet?.send(sender: (self.data?.name)!, to: na, ip: na, mess: message(delType: deliveryType.DIRECT, fromIp :(self.data?.ip)!,  sender: self.data!.name, target: na, type: messageType.SAY, text: na, data: _message))
                }
                
            //}
    
    
        }
        
    
    
    }
    
    func pollSecretFriends () {
        
        guard let fr = data?.friends else { return }
        
        //x needs to be var because of lazy connections object
        for var x in fr {
            
            let blabla = "SECRET banter"//"HULLO to "+na+" from "+(self.data?.name)!+"@"+(self.data?.ip)!
            guard let _message: Data = blabla.data(using: .utf8) else { return }
            
            //sending a message mutates x?
            
            if let encryptedMessage = x?.connections.outgoing?.send(_message) {
                
                self.mNet?.rawSend(ip: (x?.ip)!, sdata: encryptedMessage )
                
            }
        }
        
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
    
    func flushFriends() {
        
        if let x = data?.friends {
            
            if x.isEmpty { return }
            data?.friends = [friend?]()
            mNet?.debuMess("FLUSHINg friends")
            
            return }
        
        
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
        
        //guard var friendo = findFriend(name: name) else {
        guard var friendo = findFriendByIp(ip: ip) else {
            return
            
        }
        
        if friendo.connections.outgoing != nil {
            //dont handshake twice
            return;
        }
        
        
        let hs = secretHandshake(name: friendo.name, type: handshakeType.CALL, myk: nil )
        let conn = ssbConnection(name: name, ip : ip ,inbound: false, handshaked: false, terminated: false, handshake: hs, channel : nil )
        
        friendo.connections.outgoing = conn;
        
        if let seMes = friendo.connections.outgoing!.handshake!.startHandshaking(targetPubKey: friendo.publicKey!) {
            
            _ = updateFriend(f:friendo)
            
            //not a null, lets handshake
            mNet?.send(sender: (self.data?.name)!, to: friendo.name, ip: friendo.ip, mess: message(delType: deliveryType.DIRECT, fromIp : self.data!.ip, sender: self.data!.name, target: friendo.name, type: messageType.HANDSHAKE_SEND1, text: "handshaka 1", data: seMes.data))
            
                mNet?.debuMess("handshakeFriend "+friendo.name+"@"+friendo.ip);
            
            return
            
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
            mNet?.debuMess ( name + " COMPLETED handshake with " + f.name+"@"+f.ip )
        }
        
        
        //f.connections?.handshaked = true;
        _ = updateFriend(f:f)
        
        
        
        let m = "hello " + f.name + "!"
        
        say(name: f.name, _message: m.data(using: .utf8)!)
        
    }
    
    func say ( name : String , _message : Data ) {
        
        guard var friendo = findFriend(name: name) else { return }
        
        //if let encryptedMessage = friendo.connections?.channel?.say(message: _message) {
        
        
        if let encryptedMessage = friendo.connections.outgoing?.channel?.say(message: _message) {
            
            
            mNet?.send(sender: (self.data?.name)!, to: friendo.name, ip: friendo.ip, mess: message(delType: deliveryType.DIRECT, fromIp :(self.data?.ip)!,  sender: self.data!.name, target: friendo.name, type: messageType.SAY, text: "", data: encryptedMessage))
            
        }
        
        
    }
    
    func advertiseToMeshPeer (peer : Peer ) {
        
        if peer.hostname == nil { return }
        //got a mesh guy showing up
        //advertise
        /*if let friendo = findFriend(name: peer.hostname!) {
            
            return; //if friendo.connections?.channel
        }
        
        let f = friend(name: peer.hostname!, ip: peer.hostname!, publicKey: nil, ephKey: nil, connections: nil)
        addFriend(friend: f)
 
        */
        
        //serialQueue.sync {
        let m = message(delType: deliveryType.MULTICAST, fromIp: (self.data?.name)!, sender: (self.data?.name)!, target: "", type: messageType.ADVERTISE, text: (self.data?.ip)!, data: self.data?.mySsbKeys?.publicKey)    //send pub key to everyboody
        
        mNet?.debuMess("advertising to meshnet peer "+peer.hostname!+" directly")
        
        mNet?.send(sender:m.fromIp, to: peer.hostname!, ip: peer.hostname!, mess: m)
        //}
    }
    
    func advertise () {
        
        //THIS is going to so bite me on the back
        //serialQueue.sync {
            
            let m = message(delType: deliveryType.MULTICAST, fromIp: (self.data?.name)!, sender: (self.data?.name)!, target: "", type: messageType.ADVERTISE, text: (self.data?.ip)!, data: self.data?.mySsbKeys?.publicKey)    //send pub key to everyboody
        
            print ("advertising with broadcast")
        
            mNet?.broadcast(mess: m)
            
        //}
        
    }
    
    func _teardown() {
        
        //THIS is going to so bite me on the back
        let m = message(delType: deliveryType.MULTICAST, fromIp: (self.data?.name)!, sender: (self.data?.name)!, target: "", type: messageType.LOGOUT, text: (self.data?.ip)!, data: self.data?.mySsbKeys?.publicKey)    //send pub key to everyboody
        
        mNet?.debuMess((self.data?.name)!+"teardown")
        print ("teardown")
        
        //mNet?.broadcast(mess: m)
        
    }
    
    func _wakeup () {
        
        mNet?.debuMess((self.data?.name)!+"wakeup")
        print ("wakeup")
    }
    
    //nasty stuff follows
    
    func processMessage ( m: message ) {
        
        if let n = self.data?.name {
            let d = (n + " received " + m.type.rawValue + " from " + m.sender )
            print(d);
            mNet?.debuMess(d)
        }
        
        
        
        switch m.type {
            
        case messageType.HANDSHAKE_SEND1 :
            
            var friendo = findFriendByIp(ip: m.fromIp)
            
            if friendo == nil {
                
                //return
                //add a friend and we dont know his key yet
                mNet?.debuMess ("added a new friend whos trying to handshake "+m.sender)
                friendo = addFriend(friend: friend(name: m.sender, ip: m.text!, publicKey: m.data, ephKey: nil , connections: ssbConnections() ))
                
            }
            
            
            if friendo?.connections.incoming != nil {
                //continue handshake if appropriate
                
                if let seMes = friendo!.connections.incoming?.handshake?.receiveHandshakeSEND(data: m.data! ) {
                    
                    _ = updateFriend(f:friendo!)
                    
                    mNet?.send(sender: (self.data?.name)!, to: friendo!.name, ip: friendo!.ip, mess: message(delType: deliveryType.DIRECT, fromIp: (self.data?.ip)!, sender: self.data!.name, target: m.sender, type: messageType.HANDSHAKE_REPLY1, text: "shake reply 1", data: seMes.data))
                    
                } else {
                    
                    mNet?.debuMess("messageType.HANDSHAKE_SEND1 trouble at sea")
                    
                }
                return;
            } else {
                
                friendo?.connections.incoming = ssbConnection(name: friendo!.name, ip: friendo!.ip, inbound: true, handshaked: false, terminated: false, handshake: nil, channel: nil)
                
            }
            
            //create a connections obj
            
            
            let hs = secretHandshake(name: friendo!.name, type: handshakeType.RESPONSE, myk: nil )
            //let conn = ssbConnection(name: m.sender, ip: m.fromIp, inbound: true, handshaked: false, terminated: false, handshake: hs , channel : nil )
            //friendo!.connections = conn; //only one for now
            friendo?.connections.incoming?.handshake = hs
            
            _ = updateFriend(f:friendo!)
            
            if let seMes = friendo!.connections.incoming?.handshake?.receiveHandshakeSEND(data: m.data! ) {
                
                mNet?.send(sender: (self.data?.name)!, to: friendo!.name, ip: friendo!.ip, mess: message(delType: deliveryType.DIRECT, fromIp: (self.data?.ip)!, sender: self.data!.name, target: m.sender, type: messageType.HANDSHAKE_REPLY1, text: "shake reply 1", data: seMes.data))
                
            } else {
                
                mNet?.debuMess("messageType.HANDSHAKE_SEND1 trouble at sea")
                
            }
            
        
            
        case messageType.HANDSHAKE_SEND2 :
            
            //in real life this calcs more keys
            //remember to update frendo
            
            guard var friendo = findFriendByIp(ip: m.fromIp) else { return }
            
            guard let fh = friendo.connections.incoming?.handshake else {
                
                return ;
                
            }
            
            
            if let seMes = friendo.connections.incoming?.handshake?.receiveHandshakeSEND(data: m.data! ) {
                
                
                mNet?.send(sender: (self.data?.name)!, to: friendo.name, ip: friendo.ip, mess: message(delType: deliveryType.DIRECT, fromIp: (self.data?.name)!, sender: self.data!.name, target: m.sender, type: messageType.HANDSHAKE_REPLY2, text: "shake reply 2", data: seMes.data))
                
                //THIS IS A SILLY IDEA. hack for now
                let hpke = fh.targetEphPublicKey
                let mske = fh.ephKeys?.pair.secretKey
                
                friendo.connections.incoming?.handshaked = true;
                friendo.connections.incoming?.channel = ssbChannel(_hisPublicKey: hpke!, _myPrivateKey: mske!)
                
                //get rid of the handshake
                completeHandshake(f: friendo)
                
                
                
            }
        
    case messageType.HANDSHAKE_REPLY1 :
            
            guard var friendo = findFriendByIp(ip: m.fromIp) else {
                
                return
                
            }
            
            if friendo.connections.outgoing == nil {
                
                //let the guy handshaakka
                //got a reply for my owns send. if i havent initiated handshake , drop this
                return ;
                
            }
            
            if let seMes = friendo.connections.outgoing?.handshake?.receiveHandshakeREPLY(data: m.data!) {
                
                _ = updateFriend(f:friendo)
                mNet?.send(sender: (self.data?.name)!, to: friendo.name, ip: friendo.ip, mess: message(delType: deliveryType.DIRECT , fromIp: (self.data?.name)!, sender: self.data!.name, target: m.sender, type: messageType.HANDSHAKE_SEND2, text: "shake reply 2", data: seMes.data))
                
            }
            
            
            
        case messageType.HANDSHAKE_REPLY2 :
            
            //reply is outgoing
            
            guard var friendo =  findFriendByIp(ip: m.fromIp) else {
                
                return
                
            }
            
            
            if friendo.connections.outgoing?.handshake == nil { return }
            let hs = friendo.connections.outgoing?.handshake
            
            //need a handshake obj for our target
            
            let hpke = hs!.targetEphPublicKey
            let mske = hs!.ephKeys?.pair.secretKey
            
            
            if let seMes = hs!.receiveHandshakeREPLY(data: m.data!) {
                
                //ok im happy
                
                friendo.connections.outgoing?.handshaked = true;
                friendo.connections.outgoing?.channel = ssbChannel(_hisPublicKey: hpke!, _myPrivateKey: mske!)
                
                //get rid of the handshake
                completeHandshake(f: friendo)
                
                
                
            }
            
        case messageType.SAY :
            
            //got a message
            //guard var friendo = findFriend(name: m.sender) else {
            guard var friendo = findFriendByIp(ip: m.fromIp) else {
                
                return
                
            }   //from blocked user. if user is deleted = block!
            
            //if i dont have a channel yet the handshake is not complete
            
            
            
            
            if let mdat = friendo.connections.incoming?.channel?.listen(message: m.data!) {
                
                let fup = String(decoding: mdat, as: UTF8.self)
                
                let m = "||||||||  encrypted message from "+friendo.name+"@"+friendo.ip+" : "+fup
                mNet?.debuMess(m)
                //print(m)
            
            } else {
                
                //unencrypted shit maybe
                let m = "uencrypted message from "+friendo.name+"@"+friendo.ip+" : " + String(decoding: m.data!, as: UTF8.self)
                mNet?.debuMess(m)
                
            }
            
            
        case messageType.ADVERTISE :
            
            //somebody is advertizing
            
            if var friendo = findFriendByIp( ip: m.fromIp) {
            
                if var oc = friendo.connections.outgoing {
                    //already handshaking this guy
                    return;
                }
                
                    
            handshakeFriend(name: friendo.name ,ip: friendo.ip )
                
                return;
            }
            
            //return;
            
            //TODO verify the passed pub key
            
            let name = String(decoding: m.data!, as: UTF8.self)
            
            //add this exciting new acquintance immediately and start handshaking, baby
            if let friendo = addFriend(friend: friend(name: name , ip: m.fromIp, publicKey: m.data, ephKey: nil, connections: ssbConnections() )) {
                
                handshakeFriend(name: friendo.name , ip : friendo.ip )
                
            }
            
            
            return;
            
        case messageType.LOGOUT :
            
            
            self.flushFriends()
            
            
        default:
            return
        }
        
        
    }   //end process messages
    
}
