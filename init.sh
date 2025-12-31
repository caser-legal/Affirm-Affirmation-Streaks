#!/bin/bash
# init.sh - Build and install on device

# Get app name from directory
APP_NAME=$(basename "$(pwd)")
PROJECT=$(ls -d *.xcodeproj 2>/dev/null | head -1)
SCHEME="${PROJECT%.xcodeproj}"

if [ -z "$PROJECT" ]; then
    echo "❌ No .xcodeproj found"
    exit 1
fi

echo "Building $APP_NAME..."

# Build for physical device
xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
  -destination 'generic/platform=iOS' \
  -configuration Release build 2>&1 | tail -20

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build succeeded"
echo ""
echo "📱 Installing on device..."

# Find device UUID
DEVICE_ID=$(xcrun devicectl list devices 2>/dev/null | grep -E "iPhone|iPad" | head -1 | awk '{for(i=1;i<=NF;i++) if($i ~ /^[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}$/) print $i}')

if [ -z "$DEVICE_ID" ]; then
    echo "⚠️  No device found. Connect your iPhone/iPad and try again."
    exit 1
fi

echo "Found device: $DEVICE_ID"

# Install app
xcrun devicectl device install app --device "$DEVICE_ID" \
  ~/Library/Developer/Xcode/DerivedData/Build/Products/Release-iphoneos/*.app 2>&1

if [ $? -eq 0 ]; then
    echo "✅ App installed successfully!"
else
    echo "⚠️  Install may have failed. Device might be locked or busy."
fi

