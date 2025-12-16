#!/bin/bash
# Cleanup script to prepare repository for GitHub Actions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Cleaning up repository for GitHub Actions..."
echo ""

# Remove build directories
if [ -d "zmk-build" ]; then
    echo "Removing zmk-build directory..."
    rm -rf zmk-build
    echo "✓ Removed zmk-build"
fi

# Remove any UF2 files
if ls *.uf2 2>/dev/null; then
    echo "Removing UF2 files..."
    rm -f *.uf2
    echo "✓ Removed UF2 files"
fi

# Check git status
echo ""
echo "Checking git status..."
if command -v git &> /dev/null; then
    git status --short
    echo ""
    echo "Repository is ready!"
    echo ""
    echo "Next steps:"
    echo "1. Review changes: git status"
    echo "2. Add files: git add ."
    echo "3. Commit: git commit -m 'Configure OLED display'"
    echo "4. Push: git push"
    echo ""
    echo "Then check GitHub Actions for your build!"
else
    echo "Git not found, but cleanup complete."
fi
