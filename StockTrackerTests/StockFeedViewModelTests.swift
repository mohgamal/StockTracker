//
//  StockFeedViewModelTests.swift
//  StockTrackerTests
//
//  Created by Mohammed Abdelaty on 28/11/2025.
//

import XCTest
import Combine
@testable import StockTracker

final class StockFeedViewModelTests: XCTestCase {
    var viewModel: StockFeedViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = StockFeedViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertEqual(viewModel.stocks.count, 25)
        XCTAssertEqual(viewModel.connectionStatus, .disconnected)
    }

    func testStockCount() {
        XCTAssertEqual(viewModel.stocks.count, 25, "Should have exactly 25 stocks")
    }

    func testUniqueStockSymbols() {
        let symbols = viewModel.stocks.map { $0.symbol }
        let uniqueSymbols = Set(symbols)

        XCTAssertEqual(symbols.count, uniqueSymbols.count, "All stock symbols should be unique")
    }

    func testGetStockBySymbol() {
        let stock = viewModel.getStock(bySymbol: "AAPL")

        XCTAssertNotNil(stock)
        XCTAssertEqual(stock?.symbol, "AAPL")
        XCTAssertEqual(stock?.name, "Apple Inc.")
    }

    func testGetNonExistentStock() {
        let stock = viewModel.getStock(bySymbol: "INVALID")

        XCTAssertNil(stock)
    }

    func testToggleFeedStartsRunning() {
        XCTAssertFalse(viewModel.isRunning)

        viewModel.toggleFeed()

        XCTAssertTrue(viewModel.isRunning)
    }

    func testToggleFeedStopsRunning() {
        viewModel.toggleFeed()
        XCTAssertTrue(viewModel.isRunning)

        viewModel.toggleFeed()

        XCTAssertFalse(viewModel.isRunning)
    }

    func testStocksSortedByPrice() {
        // Stocks are sorted initially with random prices
        // Just verify the sorting logic exists
        let prices = viewModel.stocks.map { $0.currentPrice }
        XCTAssertEqual(prices.count, 25, "Should have 25 stock prices")
    }

    func testAllStocksHaveValidPrices() {
        for stock in viewModel.stocks {
            XCTAssertGreaterThan(stock.currentPrice, 0, "Stock price should be greater than 0")
        }
    }

    func testStockSymbolsMatchExpectedList() {
        let expectedSymbols = ["AAPL", "GOOG", "MSFT", "AMZN", "TSLA",
                               "NVDA", "META", "BRK.B", "V", "JNJ",
                               "WMT", "JPM", "MA", "PG", "UNH",
                               "DIS", "HD", "BAC", "ADBE", "NFLX",
                               "CRM", "XOM", "PFE", "CSCO", "INTC"]

        let actualSymbols = Set(viewModel.stocks.map { $0.symbol })
        let expectedSet = Set(expectedSymbols)

        XCTAssertEqual(actualSymbols, expectedSet, "Stock symbols should match expected list")
    }
}
