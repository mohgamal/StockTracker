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

    var body: some Scene {
        WindowGroup {
            FeedView()
                .environmentObject(viewModel)
        }
    }
}
