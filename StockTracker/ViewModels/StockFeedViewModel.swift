//
//  StockFeedViewModel.swift
//  StockTracker
//
//  Created by Mohammed Abdelaty on 28/11/2025.
//

import Foundation
import Combine

class StockFeedViewModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var isRunning: Bool = false

    private let webSocketService = WebSocketService()
    private var cancellables = Set<AnyCancellable>()
    private var priceUpdateTimer: Timer?

    private let stockSymbols = [
        ("AAPL", "Apple Inc."),
        ("GOOG", "Alphabet Inc."),
        ("MSFT", "Microsoft Corporation"),
        ("AMZN", "Amazon.com Inc."),
        ("TSLA", "Tesla Inc."),
        ("NVDA", "NVIDIA Corporation"),
        ("META", "Meta Platforms Inc."),
        ("BRK.B", "Berkshire Hathaway Inc."),
        ("V", "Visa Inc."),
        ("JNJ", "Johnson & Johnson"),
        ("WMT", "Walmart Inc."),
        ("JPM", "JPMorgan Chase & Co."),
        ("MA", "Mastercard Inc."),
        ("PG", "Procter & Gamble Co."),
        ("UNH", "UnitedHealth Group Inc."),
        ("DIS", "The Walt Disney Company"),
        ("HD", "The Home Depot Inc."),
        ("BAC", "Bank of America Corp."),
        ("ADBE", "Adobe Inc."),
        ("NFLX", "Netflix Inc."),
        ("CRM", "Salesforce Inc."),
        ("XOM", "Exxon Mobil Corporation"),
        ("PFE", "Pfizer Inc."),
        ("CSCO", "Cisco Systems Inc."),
        ("INTC", "Intel Corporation")
    ]

    var connectionStatus: ConnectionStatus {
        webSocketService.connectionStatus
    }

    init() {
        setupStocks()
        setupWebSocketSubscription()
    }

    private func setupStocks() {
        stocks = stockSymbols.map { symbol, name in
            Stock(symbol: symbol, name: name, initialPrice: Double.random(in: 50...500))
        }
    }

    private func setupWebSocketSubscription() {
        webSocketService.receivedMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] priceUpdate in
                self?.handlePriceUpdate(priceUpdate)
            }
            .store(in: &cancellables)

        webSocketService.$connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func toggleFeed() {
        isRunning.toggle()

        if isRunning {
            startFeed()
        } else {
            stopFeed()
        }
    }

    private func startFeed() {
        webSocketService.connect()
        startPriceUpdateTimer()
    }

    private func stopFeed() {
        stopPriceUpdateTimer()
        webSocketService.disconnect()
    }

    private func startPriceUpdateTimer() {
        // Ensure timer is created on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.priceUpdateTimer?.invalidate()
            self.priceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                self?.sendPriceUpdates()
            }

            // Add to main run loop to ensure it fires
            if let timer = self.priceUpdateTimer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }

    private func stopPriceUpdateTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.priceUpdateTimer?.invalidate()
            self?.priceUpdateTimer = nil
        }
    }

    private func sendPriceUpdates() {
        guard connectionStatus == .connected else { return }

        for stock in stocks {
            let randomChange = Double.random(in: -10...10)
            let newPrice = max(stock.currentPrice + randomChange, 1.0)

            let update = PriceUpdate(
                symbol: stock.symbol,
                price: newPrice,
                timestamp: Date()
            )

            webSocketService.sendPriceUpdate(update)
        }
    }

    private func handlePriceUpdate(_ update: PriceUpdate) {
        if let index = stocks.firstIndex(where: { $0.symbol == update.symbol }) {
            stocks[index].updatePrice(update.price)
            sortStocksByPrice()
        }
    }

    private func sortStocksByPrice() {
        stocks.sort { $0.currentPrice > $1.currentPrice }
    }

    func getStock(bySymbol symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }
}
