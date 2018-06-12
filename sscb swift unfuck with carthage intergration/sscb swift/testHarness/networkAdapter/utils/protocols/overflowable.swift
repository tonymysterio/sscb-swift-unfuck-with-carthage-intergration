//
//  overflowable.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/11.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation
import Sodium

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

    case USER_DROP  //user quota exceeded
    case OK
    case OVERFLOW_DROP  //sink full
}

typealias sinkDataSet = Set<sinkItemData>

//should we return a function that return items one by one? netadapter can consume that

class overflowableSink {
    
    lazy var _data = sinkDataSet()
    var _maxData : Int  //amount of mem this baby can eat
    var _maxItems : Int
    var _maxItemsPerSource : Int
    var _currentSizeInBytes : Int
    var _droppingUsers = Set<String>()
    
    init( maxItems : Int , maxItemsPerSource : Int , maxData : Int ){
        
        _maxItems = maxItems
        _maxItemsPerSource = maxItemsPerSource
        _maxData = maxData
        _currentSizeInBytes = 0
        
    }
    
    func currentSize() -> Int {
        
        var s : Int = 0;
        for f in _data {
            
            s = s + f._data.count
        }
        
        
        return s;
    }
    
    func _push ( _ source : String , _ data : Data ) -> sinkResponse {
    
        //first check if the personal quota is full
        
        let adu = _currentSizeInBytes + _data.count
        
        if adu > _maxData {
            
            return sinkResponse.OVERFLOW_DROP
            
        }
        
        /*if _data.count > _maxItems {
            
            return sinkResponse.OVERFLOW_DROP
            
        }*/
        
        if _data.isEmpty {
            
            //_data.append( sinkItemData(_source: source, _data: data))
            _data.insert(sinkItemData(_source: source, _data: data))
            _currentSizeInBytes = currentSize()
            return sinkResponse.OK
            
        }
        
        print (_data.count)

        //just track amount of bytes and individaul entries
        /*if _data.count > _maxItems {
            
            return sinkResponse.DROP
            
        }*/
        
        let mine = _data.filter({ $0._source == source })
            
            if mine.count > _maxItemsPerSource {
                
                _droppingUsers.insert(source)
                let uu = getUniqueSenders()
                
                if _droppingUsers.count == uu?.count {
                    
                    //everybody is dropping now
                    //user message quotas exceeded probably
                    
                    return sinkResponse.OVERFLOW_DROP
                    
                }
                //the stack is full of your shit, fuck off already
                return sinkResponse.USER_DROP
            }
            
        _data.insert( sinkItemData(_source: source, _data: data))
        
        _currentSizeInBytes = currentSize()
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
                    if f._source != us[si] {
                        //a bit tricky. we got a someone that stopped putting packets.
                        //hack fix, choose a random recipient
                        //keep rolling forward
                        //this skips entries but the next pull will empty further
                        si = si + 1;
                        if si == us.count { si = 0 }   //carousel!
                        
                        //if its not the next guy either, skip
                        if f._source != us[si] {
                            continue
                        }
                        
                    }
                    
                    buf.insert(f)
                    si = si + 1;
                    if si == us.count { si = 0 }   //carousel!
                
                    tb = tb + f._data.count
                    if tb > _maxBytes { break }
                    
                    
                    
                }
            
                if buf.isEmpty { return nil }
                
                //clean up original list
                
                let ai = _data.subtracting(buf) //all the stuff that was sent removed
                _data = ai;
                
                _currentSizeInBytes = currentSize()
                _droppingUsers = Set<String>()
                
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
        
        _currentSizeInBytes = currentSize()
        
        //clear dropping users for fairness
        _droppingUsers = Set<String>()
        
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
    //return Data( repeating: 0x00,count: b)
    return bcsDataSodium(bytes: b)
    
}

func bcsDataSodium ( bytes : Int ) -> Data {
    let sodium = Sodium()
    let randomBytes = sodium.randomBytes.buf(length: bytes)!
    return randomBytes
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
