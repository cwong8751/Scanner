//
//  UsageView.swift
//  Scanner
//
//  Created by Carl Wang on 11/1/22.
//

import SwiftUI

struct UsageView: View {
    var body: some View {
        NavigationView{
            VStack{
                
                Text("扫描")
                    .font(.headline)
                
                Text("打开应用程序的时候，相机会自动启动并寻找条码。如果要扫描条码，将屏幕中方框对准条码并等待扫描。如果扫描完成，设备会进行短暂震动并显示条码。")
                    .padding()
                
                Text("拍照")
                    .font(.headline)
                
                Text("点击拍照，程序将启动拍照界面。按下中心白色按钮进行拍照。如果确认使用照片，按 Use Photo 按钮，如果需要重新拍摄，按 Retake 按钮。")
                    .padding()
                
                Text("查看照片")
                    .font(.headline)
                
                Text("本应用程序生成的文件/照片在此位置：我的文件应用程序 》浏览 》我的iPhone 》Scanner")
                    .padding()
            }
            .navigationTitle("用法")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UsageView_Previews: PreviewProvider {
    static var previews: some View {
        UsageView()
    }
}
