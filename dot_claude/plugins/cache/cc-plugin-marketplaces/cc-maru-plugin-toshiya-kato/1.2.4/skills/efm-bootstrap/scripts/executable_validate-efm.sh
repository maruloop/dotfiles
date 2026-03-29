#!/usr/bin/env bash
set -euo pipefail

# validate-efm.sh - Validate EFM configuration
# Usage: ./validate-efm.sh <project_root>

PROJECT_ROOT="${1:-.}"
cd "$PROJECT_ROOT"

CONFIG_FILE=".claude/efm/config.yaml"
ERRORS=()

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found at $CONFIG_FILE" >&2
    exit 1
fi

# Basic YAML syntax validation
validate_yaml_syntax() {
    # Try to parse with Python if available
    if command -v python3 >/dev/null 2>&1; then
        if ! python3 -c "import yaml; yaml.safe_load(open('$CONFIG_FILE'))" 2>/dev/null; then
            ERRORS+=("YAML syntax error in config file")
        fi
    elif command -v python >/dev/null 2>&1; then
        if ! python -c "import yaml; yaml.safe_load(open('$CONFIG_FILE'))" 2>/dev/null; then
            ERRORS+=("YAML syntax error in config file")
        fi
    else
        # Fallback: basic check for common YAML issues
        if grep -q $'\t' "$CONFIG_FILE"; then
            ERRORS+=("Config file contains tabs (YAML requires spaces)")
        fi
    fi
}

# Check tool paths exist
validate_tool_paths() {
    # Extract commands from config (simplified parsing)
    local commands
    commands=$(grep -E '(lint-command|format-command):' "$CONFIG_FILE" | sed -E "s/.*: '([^']+)'.*/\1/" | awk '{print $1}')

    while IFS= read -r cmd; do
        if [[ -z "$cmd" ]]; then
            continue
        fi

        # Skip if command contains variables
        if [[ "$cmd" =~ \$ ]] || [[ "$cmd" =~ \{ ]]; then
            continue
        fi

        # Check if command exists
        if [[ ! -x "$cmd" ]] && ! command -v "$cmd" >/dev/null 2>&1; then
            ERRORS+=("Tool not found or not executable: $cmd")
        fi
    done <<< "$commands"
}

# Check wrapper scripts are executable
validate_wrappers() {
    local wrapper_dir=".claude/efm/tools"
    if [[ -d "$wrapper_dir" ]]; then
        for wrapper in "$wrapper_dir"/*.sh; do
            if [[ -f "$wrapper" && ! -x "$wrapper" ]]; then
                ERRORS+=("Wrapper script not executable: $wrapper")
            fi
        done
    fi
}

# Check required structure
validate_structure() {
    # Check for version field
    if ! grep -q '^version:' "$CONFIG_FILE"; then
        ERRORS+=("Missing 'version' field in config")
    fi

    # Check for languages section
    if ! grep -q '^languages:' "$CONFIG_FILE"; then
        ERRORS+=("Missing 'languages' section in config")
    fi
}

# Main validation flow
main() {
    validate_yaml_syntax
    validate_structure
    validate_tool_paths
    validate_wrappers

    # Report results
    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        echo "Configuration validation failed:" >&2
        for error in "${ERRORS[@]}"; do
            echo "  ❌ $error" >&2
        done
        exit 1
    else
        echo "✅ Configuration validated successfully"
        exit 0
    fi
}

main
