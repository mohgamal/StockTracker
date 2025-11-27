//
//  StockDetailView.swift
//  StockTracker
//
//  Created by Mohammed Abdelaty on 28/11/2025.
//

import SwiftUI

struct StockDetailView: View {
    @EnvironmentObject var viewModel: StockFeedViewModel
    let stock: Stock

    var currentStock: Stock {
        viewModel.getStock(bySymbol: stock.symbol) ?? stock
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                priceSection
                descriptionSection
            }
            .padding()
        }
        .navigationTitle(currentStock.symbol)
        .navigationBarTitleDisplayMode(.large)
    }

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Price")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("$\(currentStock.currentPrice, specifier: "%.2f")")
                    .font(.system(size: 48, weight: .bold))

                priceChangeIndicator
            }

            HStack(spacing: 8) {
                Text("\(currentStock.priceChangeAmount >= 0 ? "+" : "")\(currentStock.priceChangeAmount, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(priceChangeColor)

                Text("(\(currentStock.priceChangeAmount >= 0 ? "+" : "")\(currentStock.priceChangePercentage, specifier: "%.2f")%)")
                    .font(.title3)
                    .foregroundColor(priceChangeColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var priceChangeIndicator: some View {
        Group {
            switch currentStock.priceChange {
            case .up:
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
                    .font(.title)
            case .down:
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.red)
                    .font(.title)
            case .neutral:
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title)
            }
        }
    }

    private var priceChangeColor: Color {
        switch currentStock.priceChange {
        case .up:
            return .green
        case .down:
            return .red
        case .neutral:
            return .gray
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)

            Text(stockDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var stockDescription: String {
        switch currentStock.symbol {
        case "AAPL":
            return "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company is known for its innovative products including iPhone, Mac, iPad, and Apple Watch."
        case "GOOG":
            return "Alphabet Inc. operates as a holding company that provides various products and services through its subsidiaries. The company's primary business is Google, offering search, advertising, operating systems, cloud computing, and other software."
        case "MSFT":
            return "Microsoft Corporation develops, licenses, and supports software, services, devices, and solutions worldwide. The company offers Office, Windows, Azure cloud services, Xbox gaming, and LinkedIn professional networking."
        case "AMZN":
            return "Amazon.com Inc. engages in e-commerce, cloud computing, digital streaming, and artificial intelligence. The company operates through retail, AWS, advertising, and subscription services."
        case "TSLA":
            return "Tesla Inc. designs, develops, manufactures, and sells electric vehicles and energy generation and storage systems. The company is a leader in sustainable energy and autonomous driving technology."
        case "NVDA":
            return "NVIDIA Corporation provides graphics processing units (GPUs) for gaming, professional visualization, data centers, and automotive markets. The company is a leader in AI computing and accelerated computing."
        case "META":
            return "Meta Platforms Inc. builds technologies that help people connect, find communities, and grow businesses. The company operates Facebook, Instagram, WhatsApp, and is developing metaverse technologies."
        case "BRK.B":
            return "Berkshire Hathaway Inc. is a holding company owning subsidiaries engaged in insurance, freight rail transportation, utilities, manufacturing, and services. Led by Warren Buffett, it's known for value investing."
        case "V":
            return "Visa Inc. operates a global payments technology company that enables digital payments between consumers, merchants, financial institutions, and government entities worldwide."
        case "JNJ":
            return "Johnson & Johnson is a pharmaceutical, medical device, and consumer health care company. It develops, manufactures, and sells healthcare products in pharmaceuticals, medical devices, and consumer health."
        case "WMT":
            return "Walmart Inc. operates retail stores and e-commerce platforms worldwide. The company is one of the world's largest retailers, offering groceries, electronics, apparel, and home goods."
        case "JPM":
            return "JPMorgan Chase & Co. is a financial services firm offering investment banking, financial services for consumers and businesses, financial transaction processing, and asset management."
        case "MA":
            return "Mastercard Inc. operates a global payments network that connects consumers, financial institutions, merchants, and businesses in more than 210 countries and territories."
        case "PG":
            return "The Procter & Gamble Company provides branded consumer packaged goods worldwide. The company operates through Beauty, Grooming, Health Care, Fabric & Home Care, and Baby, Feminine & Family Care segments."
        case "UNH":
            return "UnitedHealth Group Inc. operates as a diversified health care company. It offers health care coverage, software, and data consultancy services through UnitedHealthcare and Optum divisions."
        case "DIS":
            return "The Walt Disney Company operates as an entertainment company worldwide. It operates through Media Networks, Parks & Resorts, Studio Entertainment, and Direct-to-Consumer & International segments."
        case "HD":
            return "The Home Depot Inc. operates as a home improvement retailer. It offers building materials, home improvement products, lawn and garden products, and provides installation services."
        case "BAC":
            return "Bank of America Corporation provides banking and financial products and services for individual consumers, small and middle-market businesses, institutional investors, and large corporations."
        case "ADBE":
            return "Adobe Inc. provides digital media and marketing solutions worldwide. The company offers Creative Cloud for content creation, Document Cloud for digital documents, and Experience Cloud for customer experiences."
        case "NFLX":
            return "Netflix Inc. provides entertainment services streaming TV series, documentaries, and feature films across various genres and languages. The company also produces original content."
        case "CRM":
            return "Salesforce Inc. provides customer relationship management (CRM) technology that brings companies and customers together. It offers cloud-based applications for sales, service, marketing, and commerce."
        case "XOM":
            return "Exxon Mobil Corporation engages in the exploration and production of crude oil and natural gas. The company also manufactures and markets petroleum products and chemical products."
        case "PFE":
            return "Pfizer Inc. discovers, develops, manufactures, and sells healthcare products worldwide. The company develops and produces medicines and vaccines for immunology, oncology, cardiology, and neurology."
        case "CSCO":
            return "Cisco Systems Inc. designs, manufactures, and sells networking and communications products and services worldwide. The company offers switching, routing, wireless, and security technologies."
        case "INTC":
            return "Intel Corporation designs, manufactures, and sells computer and communication components and products worldwide. The company develops processors, chipsets, and other semiconductor components."
        default:
            return "\(currentStock.name) is a publicly traded company listed on major stock exchanges. Track its real-time price movements and market performance through this application."
        }
    }
}

#Preview {
    NavigationStack {
        StockDetailView(stock: Stock(symbol: "AAPL", name: "Apple Inc.", initialPrice: 150.0))
            .environmentObject(StockFeedViewModel())
    }
}
