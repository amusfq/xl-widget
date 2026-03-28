#!/bin/bash
set -e

# Configuration
PROJECT="XL Widget.xcodeproj"
SCHEME="XL Widget"
CONFIGURATION="Release"
DMG_NAME="XLWidget.dmg"
APP_NAME="XL Widget.app"

# 1. Clean and Build
echo "Building the project..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIGURATION" \
    -derivedDataPath Build/ \
    -archivePath Build/XLWidget.xcarchive \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    archive -quiet

# 2. Export the .app
echo "Exporting the .app..."
# For a simple local/CI build without full code-signing setup, we can find the .app in the archive
APP_PATH=$(find Build/XLWidget.xcarchive/Products/Applications -name "$APP_NAME")

if [ -z "$APP_PATH" ]; then
    echo "Error: Could not find $APP_NAME in the archive."
    exit 1
fi

# 3. Create a staging directory for the DMG
mkdir -p Build/DMG
cp -R "$APP_PATH" Build/DMG/

# 4. Create the DMG using hdiutil (built-in) or create-dmg (if installed)
if command -v create-dmg &> /dev/null; then
    echo "Using create-dmg for a prettier DMG..."
    create-dmg \
        --volname "XL Widget" \
        --volicon "XL Widget/Assets.xcassets/AppIcon.appiconset/256.png" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "$APP_NAME" 175 190 \
        --hide-extension "$APP_NAME" \
        --app-drop-link 425 190 \
        "$DMG_NAME" \
        Build/DMG/
else
    echo "Using hdiutil to create a simple DMG..."
    hdiutil create -fs HFS+ -srcfolder Build/DMG -volname "XL Widget" -ov "$DMG_NAME"
    
    # Try to set the volume icon if we have a high-res png
    if [ -f "XL Widget/Assets.xcassets/AppIcon.appiconset/256.png" ]; then
        echo "Attempting to set volume icon..."
        # This is a bit complex for a shell script without extra tools, 
        # but hdiutil -srcfolder usually picks up .VolumeIcon.icns if present
        # For now, create-dmg is the preferred path for icons.
    fi
fi

echo "DMG created at $DMG_NAME"
