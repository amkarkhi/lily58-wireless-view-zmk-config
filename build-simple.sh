#!/bin/bash
# Simplified build script for ZMK firmware

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/zmk-build"

echo "Setting up ZMK build environment..."

# Create build directory if it doesn't exist
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Clone ZMK if not already cloned
    if [ ! -d "zmk" ]; then
        echo "Cloning ZMK repository (this may take a minute)..."
        git clone https://github.com/zmkfirmware/zmk.git
    fi
    
    cd zmk
    echo "Initializing west workspace..."
    west init -l app
    
    echo ""
    echo "Configuring west to avoid shallow clone issues..."
    # Configure west to fetch full history (not shallow)
    west config --global update.fetch false 2>/dev/null || west config update.fetch false 2>/dev/null || true
    
    echo ""
    echo "Updating west dependencies (this will download ~2-3GB, be patient)..."
    echo "If this fails, you can run manually: cd $BUILD_DIR/zmk && west update --fetch-all"
    
    # Use --fetch-all to ensure we get all tags and branches
    west update --fetch-all
    
    echo ""
    echo "Exporting Zephyr environment..."
    west zephyr-export
    
    echo ""
    echo "Setup complete!"
else
    cd "$BUILD_DIR/zmk"
    echo "Updating existing workspace..."
    west update --fetch-all || west update
fi

echo ""
echo "Building firmware..."

# Build left side
echo ""
echo "Building left side..."
west build -p -b nice_nano_v2 -- -DSHIELD=lily58_left -DZMK_CONFIG="$SCRIPT_DIR/config"

if [ $? -ne 0 ]; then
    echo "ERROR: Left side build failed!"
    exit 1
fi

# Build right side  
echo ""
echo "Building right side..."
west build -p -b nice_nano_v2 -- -DSHIELD=lily58_right -DZMK_CONFIG="$SCRIPT_DIR/config"

if [ $? -ne 0 ]; then
    echo "ERROR: Right side build failed!"
    exit 1
fi

echo ""
echo "=========================================="
echo "Build complete! UF2 files are in:"
echo "=========================================="
echo "  Left:  $BUILD_DIR/zmk/build/zephyr/zmk-nice_nano_v2-lily58_left.uf2"
echo "  Right: $BUILD_DIR/zmk/build/zephyr/zmk-nice_nano_v2-lily58_right.uf2"
echo ""
