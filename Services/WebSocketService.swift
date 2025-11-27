//
//  WebSocketService.swift
//  StockTracker
//
//  Created by Mohammed Abdelaty on 28/11/2025.
//

import Foundation
import Combine

enum ConnectionStatus {
    case connected
    case disconnected
    case connecting
}

struct PriceUpdate: Codable {
    let symbol: String
    let price: Double
    let timestamp: Date
}

class WebSocketService: NSObject, ObservableObject {
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var receivedMessage = PassthroughSubject<PriceUpdate, Never>()

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let webSocketURL = URL(string: "wss://ws.postman-echo.com/raw")!

    override init() {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }

    func connect() {
        guard connectionStatus != .connected && connectionStatus != .connecting else { return }

        connectionStatus = .connecting
        webSocketTask = urlSession?.webSocketTask(with: webSocketURL)
        webSocketTask?.resume()
        receiveMessage()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionStatus = .disconnected
    }

    func sendPriceUpdate(_ update: PriceUpdate) {
        guard connectionStatus == .connected else { return }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(update)
            let message = URLSessionWebSocketTask.Message.data(data)

            webSocketTask?.send(message) { [weak self] error in
                if let error = error {
                    print("WebSocket send error: \(error)")
                    self?.connectionStatus = .disconnected
                }
            }
        } catch {
            print("Failed to encode price update: \(error)")
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self?.connectionStatus = .disconnected
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let update = try decoder.decode(PriceUpdate.self, from: data)
                DispatchQueue.main.async {
                    self.receivedMessage.send(update)
                }
            } catch {
                print("Failed to decode message: \(error)")
            }
        case .string(let text):
            if let data = text.data(using: .utf8) {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let update = try decoder.decode(PriceUpdate.self, from: data)
                    DispatchQueue.main.async {
                        self.receivedMessage.send(update)
                    }
                } catch {
                    print("Failed to decode string message: \(error)")
                }
            }
        @unknown default:
            break
        }
    }
}

extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async {
            self.connectionStatus = .connected
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async {
            self.connectionStatus = .disconnected
        }
    }
}
