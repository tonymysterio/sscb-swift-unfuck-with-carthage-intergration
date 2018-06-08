//
//  HWnetworkAdapter.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/07.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation
import SwiftSocket
import Interstellar

struct UDPMessage  {
    
    let data : Data
    let ip : String
    let port : Int32
    
}

enum UDPMessageTypeAdaptor : String {
    
    case ADVERTISE = "ADVERT"
    case HANDSHAKE_SEND1 = "SEND1_"
    case HANDSHAKE_SEND2 = "SEND2_"
    case HANDSHAKE_REPLY1 = "REPLY1"
    case HANDSHAKE_REPLY2 = "REPLY2"
    case LOGOUT = "LOGOUT"
    case SAY = ""
    
}



var HWnetworkAdapterUDPReceivedObserver = Observable<UDPMessage>()


class HWnetworkAdapter {
    
    //throw and receive stuff over realnet
    lazy var netInfo = getIFAddresses()     //get my host name
    lazy var concurrentQueue = DispatchQueue(label: "com.queue.broadcastUDPtoLocalNetwork", attributes: .concurrent)
    
    let broadcastPort : Int32 = 8883;
    
    init() {
        
        listenUDPtrafficOnLocalNetwork()
        
    }
    
    func rawSend (ip : String ,sdata : Data ){
        
        concurrentQueue.async {
            
            let lip = "192.168.11.70"
            let client = UDPClient(address: lip, port: self.broadcastPort )
            
            client.send(data: sdata)    //has a 6 char header now that helps parsing on the other side
            
            let client2 = UDPClient(address: ip, port: self.broadcastPort )
            client2.send(data: sdata)    //has a 6 char header now that helps parsing on the other side
            
            //client.send(string: "tissi")
            let hir = "SEND raw UDP to \(lip) : \(self.broadcastPort)"
            
            self.debuMess(hir)
            //print (elmes.body)
            
        }
        
        
    }
    
    func send (sender : String, to : String, ip : String , mess : message) {
        
        //mb?.broacast(m: mess)
        
        
        guard let sdata = self.convertToTypedOutgoingUDP(mess: mess) else {
            
            return
            
        }
        
        concurrentQueue.async {
            
            /*let myIp = getIFAddresses()
            
            //we might be offline
            if myIp == nil { return }
            
            //multicast to local network
            
            let ippa = myIp[0].ip.components(separatedBy: ".")*/
            
            //let multicast = ippa[0]+"."+ippa[1]+"."+ippa[2]+".255"
            //let port : Int32 = 8883
            let lip = "192.168.11.70"
            
            
            //multicast to local network
            let client = UDPClient(address: lip, port: self.broadcastPort )
            
            client.send(data: sdata)    //has a 6 char header now that helps parsing on the other side
            
            let client2 = UDPClient(address: ip, port: self.broadcastPort )
            client2.send(data: sdata)    //has a 6 char header now that helps parsing on the other side
            
            //client.send(string: "tissi")
            let hir = "SEND UDP "+mess.type.rawValue+" to \(lip) : \(self.broadcastPort)"
            print(hir)
            self.debuMess(hir)
            //print (elmes.body)
            
        }
        
        
    }
    
    func debuMess ( _ m : String ) {
        
        concurrentQueue.async {
            
            
            let myIp = getIFAddresses()
            
            //we might be offline
            if myIp == nil { return }
            
            //multicast to local network
            
            let ippa = myIp[0].ip.components(separatedBy: ".")
            
            let multicast = ippa[0]+"."+ippa[1]+"."+ippa[2]+".255"
            
            
            let lip = "192.168.11.70"
            
            //multicast to local network
            let client = UDPClient(address: lip, port: 8884 )
            client.send(string: "#### "+m+" ####")
            
            
        }
        
        
        
    }
    
    func broadcast ( mess : message ) {
        
        //mb?.broacast(m: mess)
        let concurrentQueue = DispatchQueue(label: "com.queue.broadcastUDPtoLocalNetwork", attributes: .concurrent)
        let ip = "127.0.0.1" //mess.target
        
        guard let sdata = self.convertToTypedOutgoingUDP(mess: mess) else {
            
            return
            
        }
        
        concurrentQueue.async {
            
            let myIp = getIFAddresses()
            
            //we might be offline
            if myIp == nil { return }
            
            //multicast to local network
            
            let ippa = myIp[0].ip.components(separatedBy: ".")
            
            let multicast = ippa[0]+"."+ippa[1]+"."+ippa[2]+".255"
            //let port : Int32 = 8883
            
            
            
            //multicast to local network
            let client = UDPClient(address: multicast, port: self.broadcastPort )
            
            
            client.enableBroadcast()
            client.send(data: sdata)    //has a 6 char header now that helps parsing on the other side
            
            print ("BROADCAST UDP to \(multicast) : \(self.broadcastPort)")
            //print (elmes.body)
            
        }
        
    }
    
    
    func listenUDPtrafficOnLocalNetwork(){
        
        let ServerconcurrentQueue = DispatchQueue(label: "com.queue.Concurrent")
        
        
        let myIp = getIFAddresses()
        
        
        ServerconcurrentQueue.async {
            
            //empty means broadcast mode
            let server: UDPServer = UDPServer(address: "", port: self.broadcastPort)
            
            //let run = true
            while true {
                
                
                print("waiting")
                let (data,remoteip,remoteport)=server.recv(16000)
                //dont listen to my own bullshit
                //print(remoteip)
                if remoteip != myIp[0].ip {
                    
                    
                    
                    //skip from me to myself
                    
                    
                    if let d=data{
                        print("receive form " + remoteip)
                        
                        //convert bytes into uint8 array
                        let ca = Data(data!)
                       
                        var m = UDPMessage(data: ca, ip: remoteip, port: self.broadcastPort)
                        
                        //Cannot convert value of type '[Byte]?' (aka 'Optional<Array<UInt8>>') to expected argument type 'Data'
                        
                        //pass it to observer thats in the user objectto
                        HWnetworkAdapterUDPReceivedObserver.update(m);
                        
                        
                    }   //if this is from outside IP address
                    
                    
                } else {
                    
                    print ("onw");
                    
                }
                
                print(remoteport)
                print(remoteip)
                //server.close()
                //break
                
                
            }
            
            
        }
        
        return
        
    }
    
    func convertIncomingToTypedMessage ( delType : deliveryType , dat : Data , ip : String) -> message {
        
        let headData = dat.subdata(in:  0..<6)
        let header = String(decoding: headData, as: UTF8.self)
        var mType : messageType?
        let mData : Data?
        
        switch header {
        
        case UDPMessageTypeAdaptor.ADVERTISE.rawValue :
            mType = messageType.ADVERTISE
            mData = dat.subdata(in: 6..<dat.count  )
            
        case UDPMessageTypeAdaptor.HANDSHAKE_SEND1.rawValue :
            mType = messageType.HANDSHAKE_SEND1
            mData = dat.subdata(in: 6..<dat.count  )
            
        case UDPMessageTypeAdaptor.HANDSHAKE_REPLY1.rawValue :
            mType = messageType.HANDSHAKE_REPLY1
            mData = dat.subdata(in: 6..<dat.count  )
            
        case UDPMessageTypeAdaptor.HANDSHAKE_SEND2.rawValue :
            mType = messageType.HANDSHAKE_SEND2
            mData = dat.subdata(in: 6..<dat.count  )
            
        case UDPMessageTypeAdaptor.HANDSHAKE_REPLY2.rawValue :
            mType = messageType.HANDSHAKE_REPLY2
            mData = dat.subdata(in: 6..<dat.count  )
            
        case UDPMessageTypeAdaptor.LOGOUT.rawValue :
            mType = messageType.LOGOUT
            mData = dat.subdata(in: 6..<dat.count  )
            
        default:
            
            mType =  messageType.SAY
            mData = dat
            
        }
        
        let m = message(delType: delType, fromIp: ip, sender: ip, target: "", type: mType!, text: "blah", data: mData!)
        return m
        
    }
    
    func convertToTypedOutgoingUDP ( mess : message ) -> Data? {
        
        //make a header to deduct message type
        var header6Chars = ""
        
        
        switch (mess.type) {
            
        case messageType.ADVERTISE :
            header6Chars = UDPMessageTypeAdaptor.ADVERTISE.rawValue
            
        case messageType.HANDSHAKE_SEND1 :
            header6Chars = UDPMessageTypeAdaptor.HANDSHAKE_SEND1.rawValue
            
        case messageType.HANDSHAKE_REPLY1 :
            header6Chars = UDPMessageTypeAdaptor.HANDSHAKE_REPLY1.rawValue
            
        case messageType.HANDSHAKE_SEND2 :
            header6Chars = UDPMessageTypeAdaptor.HANDSHAKE_SEND2.rawValue
            
        case messageType.HANDSHAKE_REPLY2 :
            header6Chars = UDPMessageTypeAdaptor.HANDSHAKE_REPLY2 .rawValue
            
        case messageType.LOGOUT :
            header6Chars = UDPMessageTypeAdaptor.LOGOUT.rawValue
            
        default:
            
            header6Chars = ""
            
        }
        
        guard let m: Data = header6Chars.data(using: .utf8) else { return nil  }
        return  m + mess.data!
        
    }
    
}
