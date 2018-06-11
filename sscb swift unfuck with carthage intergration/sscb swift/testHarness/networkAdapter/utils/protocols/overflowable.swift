//
//  overflowable.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/11.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation

struct sinkItemData : Hashable,Equatable {
    let _source : String
    let _data : Data
    //var hashValue : String //= UUID().uuidString
    
    var hashValue: Int {
        return _source.hashValue ^ _data.hashValue &* 16777619
    }
    
    static func ==(lhs: sinkItemData, rhs: sinkItemData) -> Bool {
        let areEqual = lhs.hashValue == rhs.hashValue
        
        return areEqual
    }
    
    
}

enum networkSpeed : Int {
    case _2g_slow = 50000
    case _2g_fast = 70000
    case _3g = 700000
    case _4g = 7000000
}


enum sinkResponse {

    case DROP
    case OK
}

typealias sinkDataSet = Set<sinkItemData>

//should we return a function that return items one by one? netadapter can consume that

class overflowableSink {
    
    lazy var _data = sinkDataSet()
    var _maxItems : Int
    var _maxItemsPerSource : Int
    
    init( maxItems : Int , maxItemsPerSource : Int ){
        
        _maxItems = maxItems
        _maxItemsPerSource = maxItemsPerSource
        
    }
    
    
    
    func _push ( _ source : String , _ data : Data ) -> sinkResponse {
    
        //first check if the personal quota is full
        if _data.count > _maxItems {
            
            return sinkResponse.DROP
            
        }
        if _data.isEmpty {
            
            //_data.append( sinkItemData(_source: source, _data: data))
            _data.insert(sinkItemData(_source: source, _data: data))
            return sinkResponse.OK
            
        }
        
        print (_data.count)
        
        if _data.count > _maxItems {
            
            return sinkResponse.DROP
            
        }
        
        let mine = _data.filter({ $0._source == source })
            
            if mine.count > _maxItemsPerSource {
                
                //the stack is full of your shit, fuck off already
                return sinkResponse.DROP
            }
            
        _data.insert( sinkItemData(_source: source, _data: data))
        return sinkResponse.OK
        
    }
    
    func _pull ( _maxBytes : Int ) -> sinkDataSet? {
        
        //take data from different people evenly
        //get sender name and loop
        
        if _data.isEmpty { return nil }
        
        var tb = 0;
        var buf = sinkDataSet()
        
        if let us = getUniqueSenders() {
            
            if us.count > 1 {
            
                    //more senders
                //even load
                var si = 0;
                for f in _data {
                
                    //skip blobs, throw tiny data in if it bits
                    //control the flow with small maxbytes to exclude blobs
                    if (f._data.count>_maxBytes) { continue }
                    if f._source != us[si] { continue }
                    buf.insert(f)
                    si = si + 1;
                    if si>us.count { si = 0 }   //carousel!
                
                    tb = tb + f._data.count
                    if tb > _maxBytes { break }
            
                }
            
                if buf.isEmpty { return nil }
                
                //clean up original list
                
                let ai = _data.subtracting(buf) //all the stuff that was sent removed
                _data = ai;
                
                return buf;
            
            }
        }
        
        
        for f in _data {
            
            //skip blobs, throw tiny data in if it bits
            //control the flow with small maxbytes to exclude blobs
            
            
            if (f._data.count>_maxBytes) { continue }
            
            buf.insert(f)
            tb = tb + f._data.count
            if tb > _maxBytes { break }
        }
    
        if buf.isEmpty { return nil }
        
        let ai = _data.subtracting(buf) //all the stuff that was sent removed
        _data = ai;
        
        return buf;
        
        
    }
    
    //dont flush. just delete the whole object
    func getUniqueSenders () -> [String]? {
        
        var s = Set<String>()
        if _data.isEmpty { return nil }
        for f in _data {
            s.insert(f._source)
        }
        
        return Array(s)
        
    }
}

//Kbps
//maybe tone the numbers down so our app wont hog all the bandwidth?
//call this when the pipeline of stuff is empty
//if user disappears get rid of his entries somehow
//net adapter has his own strategy how many items to pull



func bcsData (mult : Int ) -> Data  {
    
    let number = Int(arc4random_uniform(UInt32(1000))) //random(in: 80 ..< 1000)
    let b = mult * (number+1)
    return Data( repeating: 0x00,count: b)
    
}

import Security

func bsData (mult : Int ) -> Data  {
    
    let number = Int(arc4random_uniform(UInt32(1000))) //random(in: 80 ..< 1000)
    let b = mult * (number+1)
    
    let bytesCount = b // number of bytes
    var randomNum: UInt32 = 0 // variable for random unsigned 32 bit integer
    var randomBytes = [UInt8](repeating: 0, count: bytesCount) // array to hold randoms bytes

    // Gen random bytes
    SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)

    // Turn bytes into data and pass data bytes into int
    return Data(bytes: randomBytes, length: bytesCount).getBytes(&randomNum, length: bytesCount)
}


/*
 
/https://wicg.github.io/netinfo/



 Table of effective connection types
 ECT    Minimum RTT (ms)    Maximum downlink (Kbps)    Explanation
 slow-2g    2000    50    The network is suited for small transfers only such as text-only pages.
 2g    1400    70    The network is suited for transfers of small images.
 3g    270    700    The network is suited for transfers of large assets such as high resolution images, audio, and SD video.
 4g    0    ∞    The network is suited for HD video, real-time video, etc.
 
 */
 
 
 
 
//overfloawable sink
//source, items

//DROP's when full

//_pull(x) , check if any items in list, return (x if we have)
