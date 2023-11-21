//
//  AnalysisView.swift
//  Scanner
//
//  Created by carl on 14/3/2022.
//

import SwiftUI
import UIKit
import AlertToast

struct AnalysisView: View {
    // 变量声明
    var barcode: String
    @State var fileStatus: String = "正在寻找图片..."
    @State var takePhoto: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var image: UIImage? = nil
    @State private var showSuccessAlert = false
    @State private var imageAddress: UIImage? = nil
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationView{
            VStack{
                // 扫描的条码显示
                Text(barcode)
                    .navigationTitle("条码分析")
                    .navigationBarTitleDisplayMode(.inline)
                    .font(.system(size: 40))
                    .onLoad{
                        let fileManager = FileManager.default
                        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let folderContents = try? fileManager.contentsOfDirectory(atPath: documentsURL.path)
                        var fileFound = false
                        
                        
                        for i in folderContents ?? [] {
                            //print("Folder contents: " + documentsURL.path + "/" + i)
                            if i.contains(barcode) {
                                fileFound = true
                                fileStatus = "有匹配图片"
                                let fpath = documentsURL.path + "/" + i
                                let fpathURL = URL(fileURLWithPath: fpath)
                                
                                do{
                                    let data = try Data(contentsOf: fpathURL)
                                    imageAddress = UIImage(data: data)
                                }
                                catch{
                                    print(error)
                                }
                                break
                            }
                        }
                        
                        if !fileFound {
                            fileStatus = "没有匹配图片"
                            takePhoto = true
                        }
                    }
                
                if(imageAddress != nil){
                    Image(uiImage: imageAddress!)
                        .resizable()
                }
                
                Text(fileStatus)
                
                if takePhoto {
                    Button("拍照") {
                        self.showImagePicker = true
                    }
                    .buttonStyle(DefaultButtonStyle())
                }
                
            }.sheet(isPresented: $showImagePicker) {
                PhotoCaptureView(showImagePicker: $showImagePicker, image: $image)
            }
            .toast(isPresenting: $showSuccessAlert){
                AlertToast(type: .regular, title: "照片保存成功")
            }
            .onChange(of: image) { img in saveImage()}
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func saveImage() {
        let imageData = image?.jpegData(compressionQuality: 0.5)
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(barcode + ".jpeg")
        
        if (try? imageData?.write(to: path)) != nil {
            showSuccessAlert = true
            presentationMode.wrappedValue.dismiss()
        }
    }
}
struct AnalysisView_Previews: PreviewProvider {
    static var barcode: String = "无条码"
    
    static var previews: some View {
        AnalysisView(barcode: barcode)
    }
}

struct ViewDidLoadModifier: ViewModifier {
    @State private var didLoad = false
    private let action: (() -> Void)?
    
    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
    
}

extension View {
    
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
    
}
