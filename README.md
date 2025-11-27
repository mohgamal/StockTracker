# StockTracker - Real-Time iOS Stock Price Tracker

A SwiftUI-based iOS application that displays real-time price updates for 25 stock symbols using WebSocket connections. Built with MVVM architecture, Combine framework, and comprehensive testing.

## Features

### Core Features
- **Real-Time Price Updates**: Tracks 25 major stock symbols with live price changes every 2 seconds
- **WebSocket Integration**: Connects to WebSocket echo server for real-time data streaming
- **Live Price Feed**: Scrollable list sorted by price (highest to lowest)
- **Connection Status**: Visual indicator showing connected/disconnected/error states
- **Stock Details**: Dedicated detail view with company information and live price updates
- **Price Indicators**: Green ↑ for increases, Red ↓ for decreases

### Bonus Features
- **Price Flash Animation**: Green/red flash on price changes with smooth fade-out
- **Comprehensive Testing**: 20 unit tests + 10 UI tests with full coverage
- **Dark Mode Support**: Fully adaptive light/dark theme using SwiftUI semantic colors
- **Deep Linking**: Custom URL scheme `stocks://symbol/{SYMBOL}` for direct navigation

## Architecture

### MVVM Pattern
```
┌─────────────────────────────────────────────────────────┐
│                         Views                            │
│  (FeedView, StockDetailView, StockRowView)              │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                      ViewModels                          │
│              (StockFeedViewModel)                        │
│  • State Management (@Published)                         │
│  • Business Logic                                        │
│  • Combine Publishers                                    │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                   Services & Models                      │
│  • WebSocketService (Combine)                           │
│  • Stock Model                                           │
│  • PriceUpdate DTO                                       │
└─────────────────────────────────────────────────────────┘
```

## Project Structure

```
StockTracker/
├── Models/
│   └── Stock.swift                 # Stock data model with price tracking
├── Services/
│   └── WebSocketService.swift     # WebSocket connection & Combine streams
├── ViewModels/
│   └── StockFeedViewModel.swift   # State management & business logic
├── Views/
│   ├── FeedView.swift             # Main feed screen with stock list
│   └── StockDetailView.swift     # Detail screen with company info
├── StockTrackerApp.swift          # App entry point & deep link handling
├── Assets.xcassets/               # App assets and colors
├── DEEP_LINKING.md                # Deep linking setup guide
└── README.md                       # This file

StockTrackerTests/
├── StockModelTests.swift           # Unit tests for Stock model
└── StockFeedViewModelTests.swift  # Unit tests for ViewModel

StockTrackerUITests/
└── StockTrackerUITests.swift      # UI automation tests
```

## Technical Implementation

### Key Technologies
- **SwiftUI**: 100% declarative UI
- **Combine**: Reactive data streams for WebSocket
- **URLSession WebSocket**: Native WebSocket implementation
- **MVVM**: Clean separation of concerns
- **XCTest**: Unit and UI testing

### State Management
- `@StateObject`: ViewModel lifecycle management
- `@Published`: Reactive state updates
- `@EnvironmentObject`: Shared state across views
- `@State`: Local view state
- `PassthroughSubject`: WebSocket message streaming

### WebSocket Implementation
```swift
// Connection Flow:
1. User taps "Start"
2. WebSocketService.connect()
3. Create URLSessionWebSocketTask
4. Wait for didOpenWithProtocol delegate
5. Start receiving messages
6. Send price updates every 2 seconds
7. Echo server returns updates
8. Decode and publish to Combine stream
9. ViewModel updates Stock models
10. SwiftUI auto-updates UI
```

## Setup & Installation

### Requirements
- Xcode 16.1+ (iOS 18.1 SDK)
- iOS 18.1+ (Simulator or Device)
- macOS 15.7.2+

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd StockTracker/StockTracker
   ```

2. **Open in Xcode**
   ```bash
   open StockTracker.xcodeproj
   ```

3. **Configure Deep Linking** (Optional)
   - Select **StockTracker** target
   - Go to **Info** tab
   - Expand **URL Types** → Click **+**
   - Set **Identifier**: `com.abdelaty.StockTracker`
   - Set **URL Schemes**: `stocks`
   - Set **Role**: `Editor`

4. **Select a Simulator or Device**
   - Choose any iOS 18.1+ simulator or device
   - Recommended: iPhone 16 Pro or iPhone 17 Pro simulator

5. **Build and Run**
   - Press `Cmd+R` or click the Play button
   - App will launch on selected device/simulator

## Usage Guide

### Basic Usage

1. **Launch the App**
   - App opens to the feed screen showing 25 stocks
   - Connection status shows "Disconnected" (red indicator)

2. **Start Live Feed**
   - Tap the green **Start** button in top-right
   - Status changes to "Connecting..." (orange)
   - Then "Connected" (green) when WebSocket connects
   - Prices begin updating every 2 seconds

3. **View Live Updates**
   - Watch prices flash green (↑) or red (↓) as they change
   - List automatically sorts by price (highest first)
   - Scroll through all 25 stocks

4. **Open Stock Details**
   - Tap any stock row to view details
   - See large price display with live updates
   - Read company description
   - Price continues updating in real-time
   - Navigate back with back button

5. **Stop Feed**
   - Tap red **Stop** button to disconnect
   - WebSocket closes gracefully
   - Status returns to "Disconnected"

### Deep Linking

Open stock details directly via URL:

**In Terminal** (with simulator running):
```bash
# Open Apple Inc. details
xcrun simctl openurl booted "stocks://symbol/AAPL"

# Open NVIDIA details
xcrun simctl openurl booted "stocks://symbol/NVDA"

# Open Tesla details
xcrun simctl openurl booted "stocks://symbol/TSLA"
```

**In Safari** (on device):
```
stocks://symbol/AAPL
stocks://symbol/GOOG
stocks://symbol/MSFT
```

**Supported Symbols**:
AAPL, GOOG, MSFT, AMZN, TSLA, NVDA, META, BRK.B, V, JNJ, WMT, JPM, MA, PG, UNH, DIS, HD, BAC, ADBE, NFLX, CRM, XOM, PFE, CSCO, INTC

### Testing Dark Mode

1. **Simulator**: Device → Appearance → Dark
2. **Device**: Settings → Display & Brightness → Dark
3. App automatically adapts all colors and UI elements

## Running Tests

### Unit Tests
```bash
# Run all unit tests
xcodebuild test -project StockTracker.xcodeproj \
  -scheme StockTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:StockTrackerTests

# Or in Xcode: Cmd+U
```

**Test Coverage:**
- ✅ Stock model initialization and updates
- ✅ Price calculation logic
- ✅ Equality and Hashable conformance
- ✅ ViewModel state management
- ✅ Stock sorting and filtering
- ✅ Symbol lookup and validation

### UI Tests
```bash
# Run UI tests
xcodebuild test -project StockTracker.xcodeproj \
  -scheme StockTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:StockTrackerUITests
```

**UI Test Coverage:**
- ✅ App launch and initial state
- ✅ Start/Stop button functionality
- ✅ Navigation to detail view
- ✅ Back navigation
- ✅ UI element existence
- ✅ Performance metrics

## Key Implementation Details

### Stock Model
```swift
struct Stock: Identifiable, Equatable, Hashable {
    let id: String
    let symbol: String
    let name: String
    var currentPrice: Double
    var priceChange: PriceChange  // .up, .down, .neutral
    var previousPrice: Double

    // Calculated properties
    var priceChangeAmount: Double
    var priceChangePercentage: Double
}
```

### WebSocket Service
- **Connection Management**: Automatic reconnection handling
- **Ping/Pong**: 20-second keepalive mechanism
- **Error Handling**: Distinguishes intentional vs error disconnects
- **Message Processing**: JSON encoding/decoding with Combine
- **Delegate Pattern**: URLSessionWebSocketDelegate for lifecycle

### Price Update Flow
```
Timer (2s) → Generate Random Price
           → Encode to JSON
           → Send via WebSocket
           → Echo Server Returns
           → Decode JSON
           → Publish to Combine
           → Update Stock Model
           → SwiftUI Re-renders
           → Flash Animation Triggers
```

## Troubleshooting

### WebSocket Connection Issues

**Problem**: "Socket is not connected" error
- **Solution**: This is a known issue with the Postman Echo WebSocket endpoint
- **Workaround**: Tap Stop, wait 2 seconds, then tap Start again
- **Note**: Connection logging shows detailed error information in console

**Problem**: Connection status shows "Error"
- **Cause**: WebSocket endpoint may be temporarily unavailable
- **Solution**: Restart the feed after a few seconds

### Build Issues

**Problem**: "Multiple commands produce Info.plist"
- **Solution**: This has been resolved - ensure you're using latest code
- **Verify**: Only auto-generated Info.plist should exist

### Deep Linking Not Working

**Problem**: URL doesn't open the app
- **Cause**: URL scheme not registered
- **Solution**: Follow setup instructions in DEEP_LINKING.md
- **Verify**: Check Target → Info → URL Types configuration

## Performance Considerations

- **List Rendering**: Uses SwiftUI's lazy rendering for smooth scrolling
- **Update Frequency**: 2-second intervals prevent UI overload
- **Memory**: Lightweight Stock models with value semantics
- **WebSocket**: Single connection shared across all views
- **Animation**: Hardware-accelerated flash animations

## Future Enhancements

Potential improvements for production deployment:

- [ ] Add stock price charts (historical data visualization)
- [ ] Implement pull-to-refresh on feed
- [ ] Add favorites/watchlist functionality
- [ ] Persist connection state across app launches
- [ ] Add haptic feedback for price changes
- [ ] Implement search/filter for stock symbols
- [ ] Add landscape mode support for iPad
- [ ] Real stock market data integration
- [ ] Push notifications for price alerts
- [ ] Widget support for lock screen

## License

This project was created as a coding challenge demonstration.

## Credits

**Developer**: Mohammed Abdelaty
**Date**: November 2025
**Framework**: SwiftUI, Combine
**Architecture**: MVVM
**WebSocket Endpoint**: wss://ws.postman-echo.com/raw

---

Built with ❤️ using SwiftUI
