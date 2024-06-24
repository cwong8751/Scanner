import UIKit
import Combine

class WebSocketViewController: UIViewController {
    
    
    //TODO: web socket doesn't get connected/ something's wrong
    var webSocketTask: URLSessionWebSocketTask?
    private var serverUrl: String = ""
    private var serverModel = ServerModel()
    private var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe the serverUrl property of the serverModel
        cancellable = serverModel.$serverUrl.sink { [weak self] url in
            guard let self = self else { return }
            if !url.isEmpty {
                self.setupWebSocket(address: url)
            }
        }
        
        // Observe the notification for URL updates
        NotificationCenter.default.addObserver(self, selector: #selector(handleServerUrlUpdated), name: Notification.Name("ServerUrlUpdated"), object: nil)
    }
    
    @objc private func handleServerUrlUpdated() {
        setupWebSocket(address: serverModel.serverUrl)
    }
    
    func setupWebSocket(address: String) {
        guard let url = URL(string: address) else {
            print("Invalid URL")
            return
        }
        
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        serverUrl = address
        
        print("web socket setup")
        
        receiveMessage()
    }
    
    func sendMessage(message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
    
    func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text message: \(text)")
                    self.receiveMessage() // Continue listening for messages
                case .data(let data):
                    print("Received data message: \(data)")
                    self.receiveMessage() // Continue listening for messages
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendMessage(message: "Hello from iPhone!")
    }
}

extension WebSocketViewController: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connection opened")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket connection closed")
    }
}
