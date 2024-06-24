//
//  ContentView.swift
//  Scanner
//
//  Created by carl on 14/3/2022.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    // 变量声明
    @State var bc:String = ""
    @State var scanSuccess:Bool = false
    @State var checkResult:Bool = false
    @State var presentUsage:Bool = false
    @State var stopScanner:Bool = false
    @State var showFindServerSheet: Bool = false
    
    // View结构
    var body: some View {
        NavigationView{
            VStack{
                
                // 扫描界面上栏
                HStack{
                    Spacer()
                    
                    Text("开始扫描")
                    Spacer()
                    
                    Button(action: {
                        showFindServerSheet.toggle()
                    }) {
                        Text("连接终端")
                            .buttonStyle(BorderlessButtonStyle())
                    }
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
                    CodeScannerView(codeTypes: [.code128], scanMode: .oncePerCode, showViewfinder: true) { response in
                        switch response {
                        case .success(let result):
                            // 更新条码结果
                            print("Found code: \(result.string)")
                            bc = result.string
                            scanSuccess = true
                            stopScanner = true
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
            .sheet(isPresented: $showFindServerSheet, content: {
                FindServerView(serverModel: ServerModel())
            })
            .padding(.top, 10)
            .ignoresSafeArea(edges: .top)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
