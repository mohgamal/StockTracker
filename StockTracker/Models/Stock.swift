//
//  Stock.swift
//  StockTracker
//
//  Created by Mohammed Abdelaty on 28/11/2025.
//

import Foundation

enum PriceChange: Equatable, Hashable {
    case up
    case down
    case neutral
}

struct Stock: Identifiable, Equatable, Hashable {
    let id: String
    let symbol: String
    let name: String
    var currentPrice: Double
    var priceChange: PriceChange
    var previousPrice: Double

    init(symbol: String, name: String, initialPrice: Double = 100.0) {
        self.id = symbol
        self.symbol = symbol
        self.name = name
        self.currentPrice = initialPrice
        self.previousPrice = initialPrice
        self.priceChange = .neutral
    }

    mutating func updatePrice(_ newPrice: Double) {
        self.previousPrice = self.currentPrice
        self.currentPrice = newPrice

        if newPrice > previousPrice {
            self.priceChange = .up
        } else if newPrice < previousPrice {
            self.priceChange = .down
        } else {
            self.priceChange = .neutral
        }
    }

    var priceChangeAmount: Double {
        currentPrice - previousPrice
    }

    var priceChangePercentage: Double {
        guard previousPrice > 0 else { return 0 }
        return ((currentPrice - previousPrice) / previousPrice) * 100
    }
}
