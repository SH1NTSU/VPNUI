//
//  Packets.swift
//  VPN
//
//  Created by Marcel Budziszewski on 12/05/2025.
//
import Network

class Packets {
    var ip: String
    var port: Int
    
    init(ip: String, port: Int) {
        self.ip = ip
        self.port = port
    }
    
    static func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                if let interface = ptr?.pointee {
                    let addrFamily = interface.ifa_addr.pointee.sa_family
                    if addrFamily == AF_INET || addrFamily == AF_INET6 {
                        if let name = String(validatingUTF8: interface.ifa_name),
                           name == "en0" || name == "pdp_ip0" {
                            var addr = interface.ifa_addr.pointee
                            let sockAddrIn = withUnsafePointer(to: &addr) {
                                $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0 }
                            }
                            let ip = String(cString: inet_ntoa(sockAddrIn.pointee.sin_addr))
                            address = ip
                        }
                    }
                }
                ptr = ptr?.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    
    // Async method to get local port
    static func getLocalPort(completion: @escaping (Int?) -> Void) {
        let connection = NWConnection(host: "8.8.8.8", port: 80, using: .udp)
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                if let localEndpoint = connection.currentPath?.remoteEndpoint {
                    if case let NWEndpoint.hostPort(_, port) = localEndpoint {
                        completion(Int(port.rawValue))
                    }
                }
                connection.cancel()
            default:
                completion(nil)
            }
        }
        connection.start(queue: .global())
    }
    
    // Convert Packet to String
    func toString() -> String {
        return "\(self.ip):\(self.port)"
    }
}


