#!/bin/bash
# Build script for ZMK firmware

# Don't exit on error immediately - we'll handle errors manually
set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/zmk-build"

echo "Setting up ZMK build environment..."

# Create build directory if it doesn't exist
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Clone ZMK if not already cloned
    if [ ! -d "zmk" ]; then
        echo "Cloning ZMK repository..."
        git clone https://github.com/zmkfirmware/zmk.git
    fi
    
    cd zmk
    west init -l app
    
    echo "Updating west dependencies (this may take a while)..."
    echo "Note: This will download several GB of dependencies..."
    
    # Configure west to not use shallow clones
    west config update.fetch false || true
    
    # Try west update - retry if it fails
    if ! west update; then
        echo "First update attempt failed, trying with --fetch-all..."
        if ! west update --fetch-all; then
            echo "Update still failed. Trying to fetch tags manually..."
            # Try to fix the zephyr repo manually
            if [ -d ".west/project-*" ] || [ -d "zephyr" ]; then
                cd zephyr 2>/dev/null || cd .west/project-*/zephyr 2>/dev/null || true
                git fetch --unshallow 2>/dev/null || git fetch --all 2>/dev/null || true
                cd - > /dev/null
            fi
            # Try update one more time
            west update --fetch-all || {
                echo "ERROR: west update failed. Please check your internet connection and try again."
                echo "You can also try running manually: cd zmk && west update --fetch-all"
                exit 1
            }
        fi
    fi
    
    echo "Exporting Zephyr environment..."
    if ! west zephyr-export; then
        echo "Warning: zephyr-export failed, but continuing..."
    fi
else
    cd "$BUILD_DIR/zmk"
    echo "Updating west dependencies..."
    west config update.fetch false || true
    if ! west update --fetch-all; then
        if ! west update; then
            echo "Warning: west update had issues, but continuing..."
        fi
    fi
fi

# Re-enable exit on error for builds
set -e

echo ""
echo "Building firmware..."

# Build left side
echo "Building left side..."
west build -p -b nice_nano_v2 -- -DSHIELD=lily58_left -DZMK_CONFIG="$SCRIPT_DIR/config"

# Build right side  
echo "Building right side..."
west build -p -b nice_nano_v2 -- -DSHIELD=lily58_right -DZMK_CONFIG="$SCRIPT_DIR/config"

echo ""
echo "Build complete! UF2 files are in:"
echo "  Left:  $BUILD_DIR/zmk/build/zephyr/zmk-nice_nano_v2-lily58_left.uf2"
echo "  Right: $BUILD_DIR/zmk/build/zephyr/zmk-nice_nano_v2-lily58_right.uf2"
