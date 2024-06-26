//
//  SocketIOManager.swift
//  Scanner
//
//  Created by Carl on 2024/6/25.
//

import Foundation
import SocketIO

class SocketIOManager: ObservableObject {
    static let shared = SocketIOManager()
    
    @Published var manager: SocketManager?
    @Published var socket: SocketIOClient?
    @Published var connectionCompletion: ((Bool) -> Void)?
    
    private init() {}
    
    func connect(url: URL, completion: @escaping (Bool) -> Void) {
        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        socket = manager?.defaultSocket
        
        socket?.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            completion(true)
        }
        
        // message receive
        socket?.on("message") { data, ack in
            if let message = data[0] as? String {
                print("received message: \(message)")
                
                // verify received message from server
                if(message == "Hello from server"){
                    print("server verfication completed")
                }
                
            } else {
                print("received unknown data: \(data)")
            }
        }
        
        socket?.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnected")
            completion(false)
        }
        
        socket?.on(clientEvent: .error) {data, ack in
            print("socket error: \(data)")
            completion(false)
        }
        
        socket?.connect()
        self.connectionCompletion = completion
    }
    
    func sendMessage(msgType: String ,message: String){
        socket?.emit(msgType, message)
    }
    
}
