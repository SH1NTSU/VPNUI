import SwiftUI

struct ContentView: View {
    @StateObject private var udpManager = UDPManager(host: "127.0.0.1", port: 55555)
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(1.3), Color.teal.opacity(0.8)]),
                           startPoint: .top,
                           endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            VStack {
    
                HStack {
                    Text("SelfVPN")
                        .font(.title2)
                        .foregroundColor(.white)
                    Spacer()
                    Text("Ping: 32ms")
                        .foregroundColor(.teal)
                }.padding()
                
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.white)
                    Text("Stara wieś")
                        .foregroundColor(.white)
                    Spacer()
                    Text("IP: 127.0.0.1")
                        .foregroundColor(.gray)
                }.padding(.horizontal)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.teal.opacity(0.5), lineWidth: 12)
                        .frame(width: 140, height: 140)
                        .shadow(color: .teal, radius: udpManager.isConnected ? 10 : 0)
                    
                    VStack() {
                        VStack {
                            Text("Status:")
                                .foregroundColor(.gray)
                            Text(udpManager.isConnected ? "Connected" : "Disconnected")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        
                        Button(action: {
                            toggleConnection()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(1))
                                    .frame(width: 143, height: 143)
                                Image(systemName: "power")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(.teal)
                            }.padding()
                        }
                    }.padding(.bottom ,63)
                }
                
                Spacer()
                
                VStack {
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    HStack {
                        VStack {
                            Text("DOWNLOAD")
                                .font(.title3)
                                .foregroundColor(.orange)
                            Text("52.2 Mbps")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                        }
                        Spacer()
                        VStack {
                            Text("UPLOAD")
                                .font(.title3)
                                .foregroundColor(.orange)
                            Text("52.2 Mbps")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                }
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                Text("Powered by SelfVPN")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
        }
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
