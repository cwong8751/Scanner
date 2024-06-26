//
//  ScannerApp.swift
//  Scanner
//
//  Created by carl on 14/3/2022.
//

import SwiftUI

@main
struct ScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(serverModel: ServerModel())
        }
    }
}
