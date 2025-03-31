import SwiftUI
struct ContentView: View {
    @StateObject private var udpManager = UDPManager(host: "127.0.0.1", port: 55555)
    
    var body: some View {
        VStack(spacing: 20) {
            Text(udpManager.connectionStatus)
                .font(.title)
                .foregroundStyle(Color.gray)
            
            Button(action: toggleConnection) {
                Image(systemName: udpManager.isConnected ? "stop.fill" : "play.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(udpManager.isConnected ? Color.blue : Color.gray)
                    .clipShape(Circle())
                    .shadow(radius: 18)
            }
        }
        .padding()
    }
    
    private func toggleConnection() {
        if udpManager.isConnected {
            udpManager.disconnect()
        } else {
            udpManager.setupConnection()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            udpManager.sendMessage("Hello World!")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
