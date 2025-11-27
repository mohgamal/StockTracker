//
//  FeedView.swift
//  StockTracker
//
//  Created by Mohammed Abdelaty on 28/11/2025.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var viewModel: StockFeedViewModel
    @State private var selectedStock: Stock?
    @Binding var deepLinkSymbol: String?

    init(deepLinkSymbol: Binding<String?> = .constant(nil)) {
        self._deepLinkSymbol = deepLinkSymbol
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                topBar
                stockList
            }
            .navigationDestination(item: $selectedStock) { stock in
                StockDetailView(stock: stock)
            }
            .onChange(of: deepLinkSymbol) { oldValue, newValue in
                if let symbol = newValue {
                    handleDeepLink(symbol)
                    deepLinkSymbol = nil
                }
            }
        }
    }

    private func handleDeepLink(_ symbol: String) {
        if let stock = viewModel.getStock(bySymbol: symbol) {
            selectedStock = stock
        } else {
            print("Stock not found for symbol: \(symbol)")
        }
    }

    private var topBar: some View {
        HStack {
            connectionStatusIndicator

            Spacer()

            feedToggleButton
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }

    private var connectionStatusIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)

            Text(statusText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var statusColor: Color {
        switch viewModel.connectionStatus {
        case .connected:
            return .green
        case .disconnected:
            return .red
        case .connecting:
            return .orange
        case .error:
            return .red
        }
    }

    private var statusText: String {
        switch viewModel.connectionStatus {
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .error:
            return "Error"
        }
    }

    private var feedToggleButton: some View {
        Button(action: {
            viewModel.toggleFeed()
        }) {
            Text(viewModel.isRunning ? "Stop" : "Start")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 80, height: 36)
                .background(viewModel.isRunning ? Color.red : Color.green)
                .cornerRadius(8)
        }
    }

    private var stockList: some View {
        List(viewModel.stocks) { stock in
            StockRowView(stock: stock)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedStock = stock
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(.plain)
    }
}

struct StockRowView: View {
    let stock: Stock
    @State private var flashColor: Color?

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.bold)

                Text(stock.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(stock.currentPrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(flashColor ?? .clear)
                            .opacity(flashColor != nil ? 0.3 : 0)
                            .padding(.horizontal, -4)
                            .padding(.vertical, -2)
                    )

                HStack(spacing: 4) {
                    priceChangeIndicator

                    Text("\(abs(stock.priceChangeAmount), specifier: "%.2f") (\(abs(stock.priceChangePercentage), specifier: "%.2f")%)")
                        .font(.caption)
                        .foregroundColor(priceChangeColor)
                }
            }
        }
        .padding(.vertical, 4)
        .onChange(of: stock.currentPrice) { oldValue, newValue in
            triggerFlash(for: stock.priceChange)
        }
    }

    private func triggerFlash(for change: PriceChange) {
        switch change {
        case .up:
            flashColor = .green
        case .down:
            flashColor = .red
        case .neutral:
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                flashColor = nil
            }
        }
    }

    private var priceChangeIndicator: some View {
        Group {
            switch stock.priceChange {
            case .up:
                Image(systemName: "arrow.up")
                    .foregroundColor(.green)
                    .font(.caption)
            case .down:
                Image(systemName: "arrow.down")
                    .foregroundColor(.red)
                    .font(.caption)
            case .neutral:
                Image(systemName: "minus")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
    }

    private var priceChangeColor: Color {
        switch stock.priceChange {
        case .up:
            return .green
        case .down:
            return .red
        case .neutral:
            return .gray
        }
    }
}

#Preview {
    FeedView(deepLinkSymbol: .constant(nil))
        .environmentObject(StockFeedViewModel())
}
