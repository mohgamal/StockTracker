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
    case error
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
    private var isConnecting = false

    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }

    func connect() {
        guard !isConnecting && connectionStatus != .connected else { return }

        isConnecting = true
        connectionStatus = .connecting

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = urlSession?.webSocketTask(with: webSocketURL)
        webSocketTask?.resume()
        receiveMessage()
    }

    func disconnect() {
        isConnecting = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionStatus = .disconnected
    }

    func sendPriceUpdate(_ update: PriceUpdate) {
        guard connectionStatus == .connected else {
            print("Cannot send: WebSocket not connected")
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(update)
            let message = URLSessionWebSocketTask.Message.data(data)

            webSocketTask?.send(message) { [weak self] error in
                if let error = error {
                    print("WebSocket send error: \(error)")
                    DispatchQueue.main.async {
                        self?.connectionStatus = .error
                    }
                }
            }
        } catch {
            print("Failed to encode price update: \(error)")
        }
    }

    private func receiveMessage() {
        guard webSocketTask != nil else { return }

        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                DispatchQueue.main.async {
                    self?.connectionStatus = .error
                    self?.isConnecting = false
                }
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
        print("WebSocket connected successfully")
        DispatchQueue.main.async {
            self.isConnecting = false
            self.connectionStatus = .connected
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "No reason"
        print("WebSocket closed with code: \(closeCode.rawValue), reason: \(reasonString)")
        DispatchQueue.main.async {
            self.isConnecting = false
            self.connectionStatus = .disconnected
        }
    }
}

extension WebSocketService: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("WebSocket task failed with error: \(error)")
            DispatchQueue.main.async {
                self.isConnecting = false
                self.connectionStatus = .error
            }
        }
    }
}
