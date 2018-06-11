//
//  overflowable.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/11.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation

struct sinkItemData {
    let _source : String
    let _data : Data
}

enum sinkResponse {

    case DROP
    case OK

}

typealias sinkDataArray = [sinkItemData?]

//should we return a function that return items one by one? netadapter can consume that

class overflowableSink {
    
    lazy var _data = sinkDataArray()
    var _maxItems : Int
    var _maxItemsPerSource : Int
    
    init( _ maxItems : Int , _ maxItemsPerSource : Int ){
        
        _maxItems = maxItems
        _maxItemsPerSource = maxItemsPerSource
        
    }
    
    
    
    func _push ( _ source : String , _ data : Data ) -> sinkResponse {
    
        //first check if the personal quota is full
        if _data.count > _maxItems { return sinkResponse.DROP }
        if _data.isEmpty {
            
            _data.append( sinkItemData(_source: source, _data: data))
            return sinkResponse.OK
            
        }
        
        let mine = _data.filter({ $0!._source == source })
            
            if mine.count > _maxItems {
                
                //the stack is full of your shit, fuck off already
                return sinkResponse.DROP
            }
            
        _data.append( sinkItemData(_source: source, _data: data))
        return sinkResponse.OK
        
    }
    
    func _pull ( _maxBytes : Int ) -> sinkDataArray? {
        
        //take data from different people evenly
        //get sender name and loop
        
        if _data.isEmpty { return nil }
        
        var tb = 0;
        var buf = sinkDataArray()
        
        if let us = getUniqueSenders() {
            
            if us.count > 1 {
            
                    //more senders
                //even load
                var si = 0;
                for f in _data {
                
                    //skip blobs, throw tiny data in if it bits
                    //control the flow with small maxbytes to exclude blobs
                    if (f!._data.count>_maxBytes) { continue }
                    if f!._source != us[si] { continue }
                    buf.append(f)
                    si = si + 1;
                    if si>us.count { si = 0 }   //carousel!
                
                    tb = tb + f!._data.count
                    if tb > _maxBytes { break }
            
                }
            
                if buf.isEmpty { return nil }
            
                return buf;
            
            }
        }
        
        
        for f in _data {
            
            //skip blobs, throw tiny data in if it bits
            //control the flow with small maxbytes to exclude blobs
            
            
            if (f!._data.count>_maxBytes) { continue }
            
            buf.append(f)
            tb = tb + f!._data.count
            if tb > _maxBytes { break }
        }
    
        if buf.isEmpty { return nil }
        
        return buf;
        
        
    }
    
    //dont flush. just delete the whole object
    func getUniqueSenders () -> [String]? {
        
        var s = Set<String>()
        if _data.isEmpty { return nil }
        for f in _data {
            s.insert(f!._source)
        }
        
        return Array(s)
        
    }
}

//Kbps
//maybe tone the numbers down so our app wont hog all the bandwidth?
//call this when the pipeline of stuff is empty
//if user disappears get rid of his entries somehow
//net adapter has his own strategy how many items to pull

enum networkSpeed : Int {
    case _2g_slow = 50000
    case _2g_fast = 70000
    case _3g = 700000
    case _4g = 7000000
}

//https://wicg.github.io/netinfo/


/*
 Table of effective connection types
 ECT    Minimum RTT (ms)    Maximum downlink (Kbps)    Explanation
 slow-2g    2000    50    The network is suited for small transfers only such as text-only pages.
 2g    1400    70    The network is suited for transfers of small images.
 3g    270    700    The network is suited for transfers of large assets such as high resolution images, audio, and SD video.
 4g    0    ∞    The network is suited for HD video, real-time video, etc./*
 
 
//overfloawable sink
//source, items

//DROP's when full

//_pull(x) , check if any items in list, return (x if we have)
