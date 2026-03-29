#!/usr/bin/env bash
set -euo pipefail

# check-fingerprint.sh - Calculate and compare project fingerprint
# Usage: ./check-fingerprint.sh <project_root>

PROJECT_ROOT="${1:-.}"
cd "$PROJECT_ROOT"

METADATA_FILE=".claude/efm/metadata.json"

# Determine hash command
HASH_CMD="sha256sum"
if ! command -v sha256sum >/dev/null 2>&1; then
    if command -v shasum >/dev/null 2>&1; then
        HASH_CMD="shasum -a 256"
    else
        echo "Error: No hash command available (sha256sum or shasum)" >&2
        exit 1
    fi
fi

# Function to hash file if it exists
hash_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        $HASH_CMD "$file" | awk '{print $1}'
    else
        echo "missing"
    fi
}

# Calculate current fingerprint
calculate_fingerprint() {
    local hash_input=""

    # Hash common config files
    local config_files=(
        "package.json"
        "package-lock.json"
        "pnpm-lock.yaml"
        "yarn.lock"
        "bun.lockb"
        "pyproject.toml"
        "requirements.txt"
        "go.mod"
        "go.sum"
        "build.gradle"
        "build.gradle.kts"
        "pom.xml"
        ".eslintrc.js"
        ".eslintrc.json"
        ".prettierrc"
        "biome.json"
        "ruff.toml"
        ".golangci.yml"
        "checkstyle.xml"
    )

    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            hash_input+=$(hash_file "$file")
        fi
    done

    # Hash generated config if exists
    if [[ -f ".claude/efm/config.yaml" ]]; then
        hash_input+=$(hash_file ".claude/efm/config.yaml")
    fi

    # Hash tool paths from PATH
    # This captures system tool changes
    for tool in eslint prettier biome ruff black mypy golangci-lint gofmt; do
        if command -v "$tool" >/dev/null 2>&1; then
            hash_input+=$(command -v "$tool")
        fi
    done

    # Calculate final hash
    echo -n "$hash_input" | $HASH_CMD | awk '{print $1}'
}

# Load existing metadata
load_metadata() {
    if [[ -f "$METADATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        cat "$METADATA_FILE"
    else
        echo "{}"
    fi
}

# Save metadata
save_metadata() {
    local hash="$1"
    local tools_json="$2"
    local languages_json="$3"

    mkdir -p "$(dirname "$METADATA_FILE")"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if command -v jq >/dev/null 2>&1; then
        jq -n \
            --arg hash "$hash" \
            --arg timestamp "$timestamp" \
            --argjson tools "$tools_json" \
            --argjson languages "$languages_json" \
            '{hash: $hash, timestamp: $timestamp, tools: $tools, languages: $languages}' \
            > "$METADATA_FILE"
    else
        # Fallback without jq
        cat > "$METADATA_FILE" <<EOF
{
  "hash": "$hash",
  "timestamp": "$timestamp",
  "tools": $tools_json,
  "languages": $languages_json
}
EOF
    fi
}

# Main flow
main() {
    local current_hash
    current_hash=$(calculate_fingerprint)

    local existing_metadata
    existing_metadata=$(load_metadata)

    local existing_hash=""
    if command -v jq >/dev/null 2>&1; then
        existing_hash=$(echo "$existing_metadata" | jq -r '.hash // ""')
    fi

    local changed="true"
    local reason="First run or metadata missing"

    if [[ -n "$existing_hash" ]]; then
        if [[ "$current_hash" == "$existing_hash" ]]; then
            changed="false"
            reason="No changes detected"
        else
            reason="Configuration files or tool paths changed"
        fi
    fi

    # Output result
    if command -v jq >/dev/null 2>&1; then
        jq -n \
            --arg changed "$changed" \
            --arg hash "$current_hash" \
            --arg reason "$reason" \
            '{changed: ($changed == "true"), hash: $hash, reason: $reason}'
    else
        cat <<EOF
{
  "changed": $changed,
  "hash": "$current_hash",
  "reason": "$reason"
}
EOF
    fi

    # Note: Actual metadata saving is done by the calling script
    # after successful config generation
}

# Export save function for use by other scripts
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
