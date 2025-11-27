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
    private var pingTimer: Timer?

    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }

    func connect() {
        guard !isConnecting && connectionStatus != .connected else {
            print("Already connecting or connected")
            return
        }

        print("Attempting to connect to WebSocket...")
        isConnecting = true
        connectionStatus = .connecting

        // Cancel any existing connection
        webSocketTask?.cancel(with: .goingAway, reason: nil)

        // Create new WebSocket task
        webSocketTask = urlSession?.webSocketTask(with: webSocketURL)
        webSocketTask?.resume()

        // Don't call receiveMessage() here - wait for didOpen delegate
    }

    func disconnect() {
        print("Disconnecting WebSocket...")
        isConnecting = false
        stopPingTimer()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionStatus = .disconnected
    }

    func sendPriceUpdate(_ update: PriceUpdate) {
        guard connectionStatus == .connected, let task = webSocketTask else {
            print("Cannot send: WebSocket not connected (status: \(connectionStatus))")
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(update)
            let message = URLSessionWebSocketTask.Message.string(String(data: data, encoding: .utf8)!)

            task.send(message) { [weak self] error in
                if let error = error {
                    print("WebSocket send error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.connectionStatus = .error
                    }
                } else {
                    print("Sent price update for \(update.symbol): $\(update.price)")
                }
            }
        } catch {
            print("Failed to encode price update: \(error)")
        }
    }

    private func receiveMessage() {
        guard let task = webSocketTask else {
            print("Cannot receive: WebSocket task is nil")
            return
        }

        task.receive { [weak self] result in
            switch result {
            case .success(let message):
                print("Received message from WebSocket")
                self?.handleMessage(message)
                // Continue receiving
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
            decodeAndPublish(data)
        case .string(let text):
            print("Received string message: \(text.prefix(100))...")
            if let data = text.data(using: .utf8) {
                decodeAndPublish(data)
            }
        @unknown default:
            break
        }
    }

    private func decodeAndPublish(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let update = try decoder.decode(PriceUpdate.self, from: data)
            print("Decoded price update for \(update.symbol): $\(update.price)")
            DispatchQueue.main.async {
                self.receivedMessage.send(update)
            }
        } catch {
            print("Failed to decode message: \(error)")
            // The echo might return the exact string we sent, which is fine
        }
    }

    private func startPingTimer() {
        stopPingTimer()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }

    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func sendPing() {
        guard connectionStatus == .connected else { return }

        webSocketTask?.sendPing { error in
            if let error = error {
                print("WebSocket ping error: \(error)")
            } else {
                print("WebSocket ping successful")
            }
        }
    }
}

extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket connected successfully!")
        DispatchQueue.main.async {
            self.isConnecting = false
            self.connectionStatus = .connected
            // Now that we're connected, start receiving messages
            self.receiveMessage()
            // Start ping timer to keep connection alive
            self.startPingTimer()
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "No reason"
        print("❌ WebSocket closed with code: \(closeCode.rawValue), reason: \(reasonString)")
        DispatchQueue.main.async {
            self.isConnecting = false
            self.stopPingTimer()
            self.connectionStatus = .disconnected
        }
    }
}

extension WebSocketService: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("❌ WebSocket task failed with error: \(error)")
            DispatchQueue.main.async {
                self.isConnecting = false
                self.stopPingTimer()
                self.connectionStatus = .error
            }
        }
    }
}
