#!/bin/bash
# Clean build script - removes existing build directory for fresh start

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/zmk-build"

if [ -d "$BUILD_DIR" ]; then
    echo "Removing existing build directory: $BUILD_DIR"
    read -p "This will delete all build files. Continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$BUILD_DIR"
        echo "Build directory removed. You can now run ./build-simple.sh for a fresh build."
    else
        echo "Cancelled."
    fi
else
    echo "No build directory found. Nothing to clean."
fi
