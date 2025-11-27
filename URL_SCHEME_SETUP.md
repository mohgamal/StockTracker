# URL Scheme Setup - Quick Fix

## The Issue
Error: `OSStatus error -10814` means no app is registered for the `stocks://` URL scheme.

## Solution: Add URL Scheme in Xcode (1 minute)

### Step-by-Step Instructions

1. **Open the project in Xcode**
   ```bash
   open StockTracker.xcodeproj
   ```

2. **Select the StockTracker target**
   - In the left sidebar, click on the blue **StockTracker** project icon
   - In the main panel, select the **StockTracker** target (under TARGETS)

3. **Go to the Info tab**
   - Click the **Info** tab at the top (next to General, Signing & Capabilities, etc.)

4. **Add URL Type**
   - Scroll down to find **URL Types** section
   - If it's collapsed, click the disclosure triangle to expand it
   - Click the **+** button at the bottom of the URL Types section

5. **Configure the URL Type**
   - **Identifier**: `com.abdelaty.StockTracker`
   - **URL Schemes**: `stocks` (click the + to add it)
   - **Role**: `Editor` (select from dropdown)

6. **Save and Build**
   - Press `Cmd+B` to build
   - The URL scheme is now registered!

### Visual Guide
```
┌─────────────────────────────────────────────┐
│ TARGETS                                      │
│  ▸ StockTracker                             │
│                                              │
│ [General] [Signing] [Resource Tags] [Info]  │ ← Click Info
│                                              │
│ Custom iOS Target Properties                │
│                                              │
│ ▾ URL Types                          [+] [-] │ ← Click + button
│   Identifier: com.abdelaty.StockTracker     │
│   URL Schemes: stocks                        │
│   Role: Editor                               │
└─────────────────────────────────────────────┘
```

## Testing After Setup

### 1. Build and Run
```bash
# In Xcode: Cmd+R
# Or terminal:
xcodebuild -project StockTracker.xcodeproj \
  -scheme StockTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

### 2. Test Deep Link
**Make sure the app is installed and running in the simulator first!**

```bash
# Open Apple stock
xcrun simctl openurl booted "stocks://symbol/AAPL"

# Open NVIDIA stock
xcrun simctl openurl booted "stocks://symbol/NVDA"

# Open Tesla stock
xcrun simctl openurl booted "stocks://symbol/TSLA"
```

### Expected Behavior
- App brings to foreground
- Navigates directly to stock detail view
- Shows the selected stock's information

## Alternative: Verify Registration

After adding the URL type, verify it's registered:

```bash
# Build the app first
xcodebuild -project StockTracker.xcodeproj -scheme StockTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Check the app's Info.plist
plutil -p ~/Library/Developer/Xcode/DerivedData/StockTracker-*/Build/Products/Debug-iphonesimulator/StockTracker.app/Info.plist | grep -A 10 CFBundleURLTypes
```

You should see:
```
"CFBundleURLTypes" => [
  0 => {
    "CFBundleURLName" => "com.abdelaty.StockTracker"
    "CFBundleURLSchemes" => [
      0 => "stocks"
    ]
  }
]
```

## Troubleshooting

### Still getting -10814 error?

1. **Clean build folder**
   ```bash
   # In Xcode: Shift+Cmd+K
   # Or Product → Clean Build Folder
   ```

2. **Delete app from simulator**
   - Long press the StockTracker app icon
   - Click "Remove App" → "Delete App"

3. **Rebuild and reinstall**
   - Press `Cmd+R` to build and run again

4. **Verify the simulator is booted**
   ```bash
   xcrun simctl list devices | grep Booted
   ```

### Wrong app opens?

If another app with `stocks://` scheme is installed:
- Delete that app from simulator
- Reinstall StockTracker

## Quick Test Script

After setup, run this script to test all symbols:

```bash
#!/bin/bash
# test-deeplinks.sh

echo "Testing deep links..."

# Make sure app is running
open -a Simulator

sleep 2

# Test various stocks
for symbol in AAPL GOOG MSFT NVDA TSLA; do
    echo "Opening $symbol..."
    xcrun simctl openurl booted "stocks://symbol/$symbol"
    sleep 3
done

echo "Deep link testing complete!"
```

Make it executable and run:
```bash
chmod +x test-deeplinks.sh
./test-deeplinks.sh
```
