# Build and Deployment Guide

## Prerequisites

### System Requirements
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- At least 4GB of free disk space

### Device Requirements
- iPhone running iOS 16.0 or later
- Or iPhone Simulator (included with Xcode)

## Initial Setup

### 1. Install Xcode

If you don't have Xcode installed:

```bash
# Option A: From Mac App Store
# Search for "Xcode" and install (recommended)

# Option B: From Apple Developer Portal
# Download from https://developer.apple.com/download/
```

After installation, accept the license:
```bash
sudo xcodebuild -license accept
```

### 2. Clone the Repository

```bash
git clone https://github.com/prettydt/backTap2.git
cd backTap2
```

### 3. Verify Project Structure

Run the verification script:
```bash
./verify_project.sh
```

All items should show ✓ (green checkmark).

## Building the App

### Option 1: Build in Xcode (Recommended)

1. **Open the project:**
   ```bash
   open backTap2.xcodeproj
   ```

2. **Select a destination:**
   - In Xcode toolbar, click the device selector (next to the scheme selector)
   - Choose an iPhone simulator (e.g., "iPhone 15 Pro")
   - Or connect a physical iPhone device

3. **Build the project:**
   - Press `⌘+B` (Command + B)
   - Or menu: Product → Build
   - Wait for compilation to complete (should take 10-30 seconds)

4. **Run the app:**
   - Press `⌘+R` (Command + R)
   - Or menu: Product → Run
   - The simulator will launch and the app will install automatically

### Option 2: Build from Command Line

```bash
# Build for simulator (iOS 16.0+)
xcodebuild -project backTap2.xcodeproj \
           -scheme backTap2 \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
           build

# Run on simulator
xcodebuild -project backTap2.xcodeproj \
           -scheme backTap2 \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
           test
```

## Troubleshooting

### Build Errors

#### Error: "No signing certificate"
**Solution:**
1. Select the project in Xcode navigator
2. Select the backTap2 target
3. Go to "Signing & Capabilities" tab
4. Check "Automatically manage signing"
5. Select your Apple ID team

#### Error: "Command PhaseScriptExecution failed"
**Solution:**
1. Go to Build Settings
2. Set "User Script Sandboxing" to NO
3. Clean build folder (⌘+Shift+K)
4. Rebuild

#### Error: "Module 'AppIntents' not found"
**Solution:**
- Ensure you're building for iOS 16.0+ target
- Check that IPHONEOS_DEPLOYMENT_TARGET = 16.0 in build settings

### Runtime Issues

#### App crashes on launch
**Solution:**
1. Check Xcode console for error messages
2. Ensure simulator is iOS 16.0 or later
3. Try resetting simulator: Device → Erase All Content and Settings

#### Charts not displaying
**Solution:**
- Charts framework is included in iOS 16+
- Verify deployment target is set correctly
- Check that demo data is loading in InMemoryStore.preview()

#### UI elements misaligned
**Solution:**
- This is a portrait-only app
- If simulator is in landscape, rotate to portrait
- Device → Rotate Left/Right (⌘+←/→)

## Running on Physical Device

### 1. Connect Your iPhone

1. Connect iPhone to Mac via USB/USB-C cable
2. Unlock iPhone and trust the Mac (if prompted)
3. iPhone should appear in Xcode's device selector

### 2. Configure Signing

1. Select project in Xcode
2. Select backTap2 target
3. Go to "Signing & Capabilities"
4. Enable "Automatically manage signing"
5. Select your Apple ID team
6. Xcode will provision the device automatically

### 3. Build and Run

1. Select your iPhone from device selector
2. Press ⌘+R to build and run
3. App will install on your device
4. If first time, may need to trust developer certificate:
   - Settings → General → VPN & Device Management
   - Tap your developer certificate
   - Tap "Trust"

## Testing the App Intent

### 1. Verify Intent Registration

After running the app once:
1. Open the Shortcuts app
2. Tap + to create new shortcut
3. Search for "Record Expense"
4. The action should appear under "Apps"

### 2. Create a Test Shortcut

1. Add "Record Expense" action
2. Configure parameters:
   - Amount: 50.00
   - Type: expense
   - Group: 饮食
   - Category: 餐饮
   - Note: Test transaction
3. Run the shortcut
4. Should see success message

### 3. Enable Back Tap

1. Settings → Accessibility → Touch → Back Tap
2. Choose Double Tap or Triple Tap
3. Scroll to Shortcuts section
4. Select your "Record Expense" shortcut
5. Test by tapping back of iPhone

## Development Workflow

### Making Changes

1. **Edit Swift files** in Xcode
2. **Test immediately** with SwiftUI Previews:
   - Open BudgetHomeView.swift
   - Canvas should show preview (⌥+⌘+↵)
   - Interact with preview in real-time
3. **Build and run** to test on simulator
4. **Commit changes** when working

### Debugging

**Print statements:**
```swift
print("Debug: Budget updated to \(amount)")
```

**Breakpoints:**
- Click line number gutter in Xcode to set breakpoint
- Run in debug mode (⌘+R)
- Inspect variables when stopped

**Instruments:**
- Product → Profile (⌘+I)
- Choose "Time Profiler" or "Leaks"
- Analyze performance issues

### Common Xcode Shortcuts

- `⌘+B` - Build
- `⌘+R` - Run
- `⌘+.` - Stop
- `⌘+Shift+K` - Clean build folder
- `⌘+Shift+O` - Open quickly (search files)
- `⌃+6` - Jump to function/method
- `⌥+⌘+↵` - Show/hide preview canvas
- `⌘+0` - Show/hide navigator
- `⌘+Shift+Y` - Show/hide debug area

## Deployment Checklist

Before submitting to App Store (future):

- [ ] Update version number in project settings
- [ ] Add app icon (1024x1024 required)
- [ ] Test on multiple device sizes (SE, 15, 15 Pro Max)
- [ ] Test on real device, not just simulator
- [ ] Verify all intents are properly registered
- [ ] Run performance profiling
- [ ] Check for memory leaks
- [ ] Test in different locales (if supporting multiple languages)
- [ ] Create screenshots for App Store
- [ ] Write App Store description
- [ ] Configure App Store Connect

## Performance Benchmarks

Expected build times (M1 Mac):
- **Clean build**: 15-30 seconds
- **Incremental build**: 3-5 seconds
- **SwiftUI preview refresh**: 1-2 seconds

Expected app metrics:
- **App size**: ~5-10 MB (before App Thinning)
- **Memory usage**: 50-100 MB
- **Launch time**: <1 second

## Continuous Integration (Future)

For automated builds:

```yaml
# .github/workflows/ios.yml
name: iOS CI
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: |
          xcodebuild -project backTap2.xcodeproj \
                     -scheme backTap2 \
                     -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
                     build
```

## Resources

- **Apple Documentation**: https://developer.apple.com/documentation/
- **SwiftUI Tutorials**: https://developer.apple.com/tutorials/swiftui
- **App Intents Guide**: https://developer.apple.com/documentation/appintents
- **Xcode Help**: Help → Xcode Help in menu

## Support

If you encounter issues:
1. Check the TESTING.md file for known issues
2. Clean build folder (⌘+Shift+K) and retry
3. Reset simulator or restart Xcode
4. Check Xcode console for detailed error messages
5. Open an issue on GitHub with error details

---

**Last Updated**: December 2024
