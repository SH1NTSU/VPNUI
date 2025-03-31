import Foundation
import Network

class UDPManager: ObservableObject {
    private var connection: NWConnection?
    private let host: NWEndpoint.Host
    private let port: NWEndpoint.Port
    
    @Published var connectionStatus: String = "Discontected"
    @Published var isConnected: Bool = false
    
    init(host: String, port: UInt16) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(integerLiteral: port)
    }
    
    func setupConnection() {
        connection = NWConnection(host: host, port: port, using: .udp)
        
        connection?.stateUpdateHandler = { [weak self] newState in guard let self = self else {return}
            DispatchQueue.main.async {
                switch newState {
                case .ready:
                    self.connectionStatus = "Connected"
                    self.isConnected = true
                case .failed(let error):
                    self.connectionStatus = "Connection failed"
                    self.isConnected = false
                case .cancelled:
                    self.connectionStatus = "Discontected"
                    self.isConnected = false
                default :
                    break
                }
            }
        }
        connection?.start(queue: .global())
    }
    

    func sendMessage(_ message: String) {
        guard let connection = connection else { return }
        
        let data = Data(message.utf8)
        
        
        connection.send(content: data, completion: .contentProcessed{ [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.connectionStatus = "Send Failed"
                    print("Error sending message: \(error)")
                } else {
                    print("Message sent successfully")
                }
            }
        })
        
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
    }
}
