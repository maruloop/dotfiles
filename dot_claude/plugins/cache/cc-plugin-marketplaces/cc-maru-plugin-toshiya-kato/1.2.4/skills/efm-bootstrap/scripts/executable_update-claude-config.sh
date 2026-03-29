#!/usr/bin/env bash
set -euo pipefail

# update-claude-config.sh - Update ClaudeCode LSP configuration
# Usage: ./update-claude-config.sh <project_root> <languages_json>

PROJECT_ROOT="${1:-.}"
LANGUAGES_JSON="${2:-[]}"

# Detect ClaudeCode config location
detect_config_location() {
    # Check environment variable first
    if [[ -n "${CLAUDE_CODE_CONFIG:-}" ]]; then
        echo "$CLAUDE_CODE_CONFIG"
        return 0
    fi

    # Check common locations
    local locations=(
        "$HOME/.config/claude-code/settings.json"
        "$HOME/.claude-code/settings.json"
        "$HOME/Library/Application Support/claude-code/settings.json"
    )

    for location in "${locations[@]}"; do
        if [[ -f "$location" ]]; then
            echo "$location"
            return 0
        fi
    done

    # Default location
    echo "$HOME/.config/claude-code/settings.json"
}

# Get project name for unique server ID
get_project_name() {
    basename "$PROJECT_ROOT"
}

# Main update flow
main() {
    local config_file
    config_file=$(detect_config_location)

    local project_name
    project_name=$(get_project_name)

    local server_id="efm-${project_name}"
    local start_script="$PROJECT_ROOT/.claude/efm/start.sh"

    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        echo "Warning: jq not found, cannot update ClaudeCode config" >&2
        echo "Install jq to enable automatic LSP registration" >&2
        echo ""
        echo "Manual registration:"
        echo "  Add to $config_file:"
        echo "  {"
        echo "    \"languageServers\": {"
        echo "      \"$server_id\": {"
        echo "        \"command\": \"$start_script\","
        echo "        \"filetypes\": $LANGUAGES_JSON"
        echo "      }"
        echo "    }"
        echo "  }"
        return 1
    fi

    # Ensure config directory exists
    mkdir -p "$(dirname "$config_file")"

    # Create or update config
    if [[ ! -f "$config_file" ]]; then
        # Create new config
        jq -n \
            --arg server_id "$server_id" \
            --arg command "$start_script" \
            --argjson filetypes "$LANGUAGES_JSON" \
            '{languageServers: {($server_id): {command: $command, args: [], filetypes: $filetypes}}}' \
            > "$config_file"
        echo "Created ClaudeCode config at: $config_file"
    else
        # Update existing config
        local tmp_file
        tmp_file=$(mktemp)

        jq \
            --arg server_id "$server_id" \
            --arg command "$start_script" \
            --argjson filetypes "$LANGUAGES_JSON" \
            '.languageServers //= {} | .languageServers[$server_id] = {command: $command, args: [], filetypes: $filetypes}' \
            "$config_file" > "$tmp_file"

        mv "$tmp_file" "$config_file"
        echo "Updated ClaudeCode config at: $config_file"
    fi

    echo "Registered EFM server as: $server_id"
    echo "Languages: $LANGUAGES_JSON"
}

main
