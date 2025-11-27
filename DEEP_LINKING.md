# Deep Linking Configuration

The app supports deep linking with the custom URL scheme: `stocks://symbol/{SYMBOL}`

## Setup Instructions

To enable deep linking, you need to register the custom URL scheme in Xcode:

1. Open the project in Xcode
2. Select the **StockTracker** target
3. Go to the **Info** tab
4. Expand **URL Types**
5. Click the **+** button to add a new URL type
6. Configure as follows:
   - **Identifier**: `com.abdelaty.StockTracker`
   - **URL Schemes**: `stocks`
   - **Role**: `Editor`

## Testing Deep Links

### In Simulator:
```bash
xcrun simctl openurl booted "stocks://symbol/AAPL"
xcrun simctl openurl booted "stocks://symbol/GOOG"
xcrun simctl openurl booted "stocks://symbol/TSLA"
```

### On Device:
- Open Safari and enter: `stocks://symbol/AAPL`
- Or use a test app with `UIApplication.shared.open(url)`

## Supported Symbols

The app supports deep links to any of the 25 tracked symbols:
- AAPL, GOOG, MSFT, AMZN, TSLA, NVDA, META, BRK.B, V, JNJ
- WMT, JPM, MA, PG, UNH, DIS, HD, BAC, ADBE, NFLX
- CRM, XOM, PFE, CSCO, INTC

## URL Format

`stocks://symbol/{SYMBOL}`

Where `{SYMBOL}` is the stock ticker symbol (case-insensitive).

### Examples:
- `stocks://symbol/AAPL` - Opens Apple Inc. detail view
- `stocks://symbol/nvda` - Opens NVIDIA Corp. detail view (case-insensitive)
- `stocks://symbol/INVALID` - Logs error, stays on feed screen
