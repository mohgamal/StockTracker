//
//  StockTrackerApp.swift
//  StockTracker
//
//  Created by Mohammed Abdelaty on 28/11/2025.
//

import SwiftUI

@main
struct StockTrackerApp: App {
    @StateObject private var viewModel = StockFeedViewModel()
    @State private var deepLinkSymbol: String?

    var body: some Scene {
        WindowGroup {
            FeedView(deepLinkSymbol: $deepLinkSymbol)
                .environmentObject(viewModel)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        // Handle stocks://symbol/{SYMBOL} format
        guard url.scheme == "stocks",
              url.host == "symbol",
              let symbol = url.pathComponents.last,
              symbol != "/" else {
            print("Invalid deep link URL: \(url)")
            return
        }

        print("Deep link to symbol: \(symbol)")
        deepLinkSymbol = symbol.uppercased()
    }
}
