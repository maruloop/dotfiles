#!/usr/bin/env bash
set -euo pipefail

# install-wrappers.sh - Install and customize wrapper scripts
# Usage: ./install-wrappers.sh <project_root> <tools_list>

PROJECT_ROOT="${1:-.}"
TOOLS_LIST="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER_SOURCE_DIR="$(dirname "$SCRIPT_DIR")/wrappers"
WRAPPER_TARGET_DIR="$PROJECT_ROOT/.claude/efm/tools"

# Create target directory
mkdir -p "$WRAPPER_TARGET_DIR"

# Check if tools list contains checkstyle
if echo "$TOOLS_LIST" | grep -q "checkstyle"; then
    echo "Installing checkstyle wrapper..."

    # Copy wrapper
    cp "$WRAPPER_SOURCE_DIR/checkstyle-wrapper.sh" "$WRAPPER_TARGET_DIR/checkstyle-wrapper.sh"

    # Customize wrapper with project root
    sed -i.bak "s|{{PROJECT_ROOT}}|$PROJECT_ROOT|g" "$WRAPPER_TARGET_DIR/checkstyle-wrapper.sh"
    rm -f "$WRAPPER_TARGET_DIR/checkstyle-wrapper.sh.bak"

    # Make executable
    chmod +x "$WRAPPER_TARGET_DIR/checkstyle-wrapper.sh"

    echo "Checkstyle wrapper installed at: $WRAPPER_TARGET_DIR/checkstyle-wrapper.sh"
fi

# Add more wrapper installations here as needed

echo "Wrapper installation complete"
