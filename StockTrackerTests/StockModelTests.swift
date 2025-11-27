//
//  StockModelTests.swift
//  StockTrackerTests
//
//  Created by Mohammed Abdelaty on 28/11/2025.
//

import XCTest
@testable import StockTracker

final class StockModelTests: XCTestCase {

    func testStockInitialization() {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 150.0)

        XCTAssertEqual(stock.symbol, "AAPL")
        XCTAssertEqual(stock.name, "Apple Inc.")
        XCTAssertEqual(stock.currentPrice, 150.0)
        XCTAssertEqual(stock.previousPrice, 150.0)
        XCTAssertEqual(stock.priceChange, .neutral)
    }

    func testUpdatePriceIncrease() {
        var stock = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 100.0)

        stock.updatePrice(110.0)

        XCTAssertEqual(stock.currentPrice, 110.0)
        XCTAssertEqual(stock.previousPrice, 100.0)
        XCTAssertEqual(stock.priceChange, .up)
        XCTAssertEqual(stock.priceChangeAmount, 10.0)
    }

    func testUpdatePriceDecrease() {
        var stock = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 100.0)

        stock.updatePrice(90.0)

        XCTAssertEqual(stock.currentPrice, 90.0)
        XCTAssertEqual(stock.previousPrice, 100.0)
        XCTAssertEqual(stock.priceChange, .down)
        XCTAssertEqual(stock.priceChangeAmount, -10.0)
    }

    func testUpdatePriceNoChange() {
        var stock = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 100.0)

        stock.updatePrice(100.0)

        XCTAssertEqual(stock.currentPrice, 100.0)
        XCTAssertEqual(stock.previousPrice, 100.0)
        XCTAssertEqual(stock.priceChange, .neutral)
        XCTAssertEqual(stock.priceChangeAmount, 0.0)
    }

    func testPriceChangePercentage() {
        var stock = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 100.0)

        stock.updatePrice(120.0)

        XCTAssertEqual(stock.priceChangePercentage, 20.0, accuracy: 0.01)
    }

    func testPriceChangePercentageDecrease() {
        var stock = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 100.0)

        stock.updatePrice(80.0)

        XCTAssertEqual(stock.priceChangePercentage, -20.0, accuracy: 0.01)
    }

    func testMultipleUpdates() {
        var stock = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 100.0)

        stock.updatePrice(110.0)
        XCTAssertEqual(stock.priceChange, .up)

        stock.updatePrice(105.0)
        XCTAssertEqual(stock.priceChange, .down)
        XCTAssertEqual(stock.previousPrice, 110.0)
        XCTAssertEqual(stock.currentPrice, 105.0)
    }

    func testStockEquality() {
        let stock1 = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 150.0)
        let stock2 = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 150.0)

        XCTAssertEqual(stock1, stock2)
    }

    func testStockHashable() {
        let stock1 = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 150.0)
        let stock2 = Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 150.0)

        var set = Set<Stock>()
        set.insert(stock1)
        set.insert(stock2)

        XCTAssertEqual(set.count, 1)
    }
}
