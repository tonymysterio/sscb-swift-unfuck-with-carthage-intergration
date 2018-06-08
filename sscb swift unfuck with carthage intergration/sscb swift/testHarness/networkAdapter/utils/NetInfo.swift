//
//  NetInfo.swift
//  sscb swift unfuck with carthage intergration
//
//  Created by sami on 2018/06/07.
//  Copyright © 2018年 osuuskunta hastur. All rights reserved.
//

import Foundation

struct NetInfo {
    let ip: String
    let netmask: String
}

// Get the local ip addresses used by this node
func getIFAddresses() -> [NetInfo] {
    var addresses = [NetInfo]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
    if getifaddrs(&ifaddr) == 0 {
        
        var ptr = ifaddr;
        while ptr != nil {
            
            let flags = Int32((ptr?.pointee.ifa_flags)!)
            var addr = ptr?.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr?.sa_family == UInt8(AF_INET) || addr?.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        if let address = String.init(validatingUTF8:hostname) {
                            
                            var net = ptr?.pointee.ifa_netmask.pointee
                            var netmaskName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            getnameinfo(&net!, socklen_t((net?.sa_len)!), &netmaskName, socklen_t(netmaskName.count),
                                        nil, socklen_t(0), NI_NUMERICHOST)// == 0
                            if let netmask = String.init(validatingUTF8:netmaskName) {
                                addresses.append(NetInfo(ip: address, netmask: netmask))
                            }
                        }
                    }
                }
            }
            ptr = ptr?.pointee.ifa_next
        }
        freeifaddrs(ifaddr)
    }
    return addresses
}
