//
//  ContentView.swift
//  Scanner
//
//  Created by carl on 14/3/2022.
//

import SwiftUI
import CodeScanner
import AlertToast

struct ContentView: View {
    // 变量声明
    @State var bc:String = ""
    @State var scanSuccess:Bool = false
    @State var checkResult:Bool = false
    @State var presentUsage:Bool = false
    @State var stopScanner:Bool = false
    
    @ObservedObject var serverModel: ServerModel
//    @StateObject public var socketIOManager = SocketIOManager()
    
    @State private var showErrorAlert: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var errorString: String = ""
    @State private var successString: String = ""
    
    
    // View结构
    var body: some View {
        NavigationView{
            VStack{
                // 扫描界面上栏
                HStack{
                    Spacer()
                    
                    Text("开始扫描")
                    Spacer()
                }
                .padding(.top, 15)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                
                if #available(iOS 15.0, *) {
                    TextField("键入条码", text: $bc)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .onSubmit {
                            scanSuccess = true
                        }
                }
                
                // 初始化扫描仪View
                if(!stopScanner){
                    CodeScannerView(codeTypes: [.code128, .qr], scanMode: .oncePerCode, showViewfinder: true) { response in
                        switch response {
                        case .success(let result):
                            // 更新条码结果
                            print("Found code: \(result.string)")
                            
                            // check code type
                            if(result.type == .qr && isWebSocketURL(result.string)){
                                serverModel.serverUrl = result.string
                                print(serverModel.serverUrl)
                                
                                // start connection
                                DispatchQueue.main.async {
                                    if let url = URL(string: serverModel.serverUrl) {
                                        SocketIOManager.shared.connect(url: url) { isConnected in
                                            if isConnected {
                                                successString = "连接成功"
                                                showSuccessAlert = true
                                                
                                                // send verification message
                                                    SocketIOManager.shared.sendMessage(msgType: "message", message: "Hello from " + UIDevice.current.name)
                                            } else {
                                                errorString = "连接失败"
                                                showErrorAlert = true
                                            }
                                        }
                                    } else {
                                        print("Invalid URL")
                                    }
                                }
                            }
                            
                            if(result.type == .code128){
                                scanSuccess = true
                                stopScanner = true
                                bc = result.string
                            }
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
                
                // 初始化条码显示区
                HStack{
                    Text(bc)
                        .font(.system(size: 30))
                }.padding()
            }
            // 扫描条码打开分析界面
            .sheet(isPresented: $scanSuccess){
                // 打开AnalysisView，传入扫描的变量
                AnalysisView(barcode: bc)
                //关闭View的时候把扫描界面条码显示变量设为无条码，方便用户识别并开启下次扫描
                    .onDisappear{
                        bc = ""
                        stopScanner = false
                    }
            }
            .toast(isPresenting: $showErrorAlert, duration: 2.0) {
                AlertToast(displayMode: .alert, type: .error(Color.red), title: errorString)
            }
            .toast(isPresenting: $showSuccessAlert, duration: 2.0) {
                AlertToast(displayMode: .alert, type: .systemImage("checkmark", Color.green), title: successString)
            }
            .padding(.top, 10)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func isWebSocketURL(_ urlString: String) -> Bool {
        let pattern = #"^wss?:\/\/[\w\-\.]+(:\d+)?(\/[^\s]*)?$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: urlString.utf16.count)
        return regex?.firstMatch(in: urlString, options: [], range: range) != nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(serverModel: ServerModel())
    }
}
