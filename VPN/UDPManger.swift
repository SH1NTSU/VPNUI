import Foundation
import Network
import CryptoKit

class UDPManager: ObservableObject {
    private var connection: NWConnection?
    private let host: NWEndpoint.Host
    private let port: NWEndpoint.Port
    private let key: SymmetricKey
    
    @Published var connectionStatus: String = "Disconnected"
    @Published var isConnected: Bool = false
    
    init(host: String, port: UInt16) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(integerLiteral: port)
        self.key = SymmetricKey(data: Data("your-32-byte-secure-key-string!2".utf8))
    }
    
    func setupConnection() {
        connection = NWConnection(host: host, port: port, using: .udp)
        
        connection?.stateUpdateHandler = { [weak self] newState in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch newState {
                case .ready:
                    self.connectionStatus = "Connected"
                    self.isConnected = true
                    print("UDP connection ready")
                case .failed(let error):
                    self.connectionStatus = "Connection failed: \(error.localizedDescription)"
                    self.isConnected = false
                    print("Connection failed: \(error)")
                case .cancelled:
                    self.connectionStatus = "Disconnected"
                    self.isConnected = false
                    print("Connection cancelled")
                default:
                    print("Connection state changed to \(newState)")
                    break
                }
            }
        }
        
        // Start the connection
        connection?.start(queue: .global(qos: .userInitiated))
    }
    
    func encryptMessage(_ message: String) -> (combined: Data, nonce: Data, tag: Data)? {
        let data = Data(message.utf8)
        let nonce = AES.GCM.Nonce()  // Generates 12-byte nonce
        let add = Data("auth_data".utf8)
        do {
            let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce, authenticating: add)
            
            guard let combined = sealedBox.combined else {
                print("Error: Failed to get combined data")
                return nil
            }
            
            print("[Swift] Encryption details:")
            print("Nonce (12 bytes): \(sealedBox.nonce.withUnsafeBytes { Data($0).hexString })")
            
            return (combined, Data(sealedBox.nonce), sealedBox.tag)
        } catch {
            print("Encryption failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    func sendMessage(_ message: String) {
        guard let connection = connection else {
            print("Error: No active connection")
            return
        }
        
        guard connection.state == .ready else {
            print("Error: Connection is not ready")
            return
        }
        
        guard let (combined, nonce, tag) = encryptMessage(message) else {
            print("Error: Failed to encrypt message")
            return
        }
        
        // Send the encrypted data
        connection.send(content: combined, completion: .contentProcessed { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.connectionStatus = "Send Failed"
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    print("Message sent successfully")
                }
            }
        })
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
        connectionStatus = "Disconnected"
        isConnected = false
        print("Connection terminated")
    }
}

// Hex string extension
extension Data {
    var hexString: String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}

