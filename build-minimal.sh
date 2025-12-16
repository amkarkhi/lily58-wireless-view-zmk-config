#!/bin/bash
# Minimal build script - only downloads what's absolutely necessary
# Use this ONLY if you can't use GitHub Actions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/zmk-build"

echo "=========================================="
echo "MINIMAL BUILD SCRIPT"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will still download ~3-5GB"
echo "💡 RECOMMENDED: Use GitHub Actions instead!"
echo "   See BUILD_WITH_GITHUB.md"
echo ""
read -p "Continue with local build? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled. Use GitHub Actions for slow internet!"
    exit 0
fi

echo ""
echo "Setting up minimal ZMK build..."

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Clone ZMK (this is still ~100MB, but necessary)
if [ ! -d "zmk" ]; then
    echo "Cloning ZMK repository (this is the smallest download)..."
    git clone --depth 1 --branch v0.3 https://github.com/zmkfirmware/zmk.git
fi

cd zmk

# Initialize west
if [ ! -d ".west" ]; then
    echo "Initializing west..."
    west init -l app
fi

# Configure to minimize downloads
echo "Configuring for minimal downloads..."
west config update.fetch false 2>/dev/null || true

# Update dependencies (this is the big download, but we need it)
echo ""
echo "Downloading dependencies (this is the slow part)..."
echo "This will download ~2-3GB. Go grab a coffee! ☕"
west update --fetch-all

# Export Zephyr
west zephyr-export

# Build
echo ""
echo "Building firmware..."
west build -p -b nice_nano_v2 -- -DSHIELD=lily58_left -DZMK_CONFIG="$SCRIPT_DIR/config"
west build -p -b nice_nano_v2 -- -DSHIELD=lily58_right -DZMK_CONFIG="$SCRIPT_DIR/config"

echo ""
echo "Build complete!"
echo "UF2 files: $BUILD_DIR/zmk/build/zephyr/"
