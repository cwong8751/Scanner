import SwiftUI
import CodeScanner

struct FindServerView: View {
    @ObservedObject var serverModel: ServerModel

    var body: some View {
        VStack {
            Text("连接终端").padding()
            CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, showViewfinder: true) { response in
                switch response {
                case .success(let result):
                    serverModel.serverUrl = result.string
                    print(serverModel.serverUrl)
                    
                    // Here, notify the view controller to set up the WebSocket
                    NotificationCenter.default.post(name: Notification.Name("ServerUrlUpdated"), object: nil)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    FindServerView(serverModel: ServerModel())
}
