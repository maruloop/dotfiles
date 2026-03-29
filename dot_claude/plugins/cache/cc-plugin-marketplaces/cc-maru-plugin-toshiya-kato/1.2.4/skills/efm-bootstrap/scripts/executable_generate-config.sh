#!/usr/bin/env bash
set -euo pipefail

# generate-config.sh - Generate EFM config from templates
# Usage: ./generate-config.sh <project_root> <tools_json> <resolved_paths_json>

PROJECT_ROOT="${1:-.}"
TOOLS_JSON="${2:-{}}"
RESOLVED_PATHS_JSON="${3:-{}}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")/templates"
OUTPUT_DIR="$PROJECT_ROOT/.claude/efm"
OUTPUT_FILE="$OUTPUT_DIR/config.yaml"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Start with base config
cp "$TEMPLATE_DIR/base.yaml" "$OUTPUT_FILE"

# Parse tools and paths
declare -A TOOL_PATHS
if command -v jq >/dev/null 2>&1; then
    # Parse resolved paths into associative array
    while IFS="=" read -r tool path; do
        TOOL_PATHS["$tool"]="$path"
    done < <(echo "$RESOLVED_PATHS_JSON" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' 2>/dev/null || true)
fi

# Function to append tool fragment to config
append_tool_fragment() {
    local tool="$1"
    local language="$2"
    local tool_path="${TOOL_PATHS[$tool]:-}"

    if [[ -z "$tool_path" ]]; then
        echo "Warning: No path found for tool '$tool', skipping" >&2
        return
    fi

    local fragment_file="$TEMPLATE_DIR/${tool}.yaml"
    if [[ ! -f "$fragment_file" ]]; then
        echo "Warning: No template found for tool '$tool', skipping" >&2
        return
    fi

    # Read fragment and substitute paths
    local fragment_content
    fragment_content=$(cat "$fragment_file")

    # Handle wrapper path for checkstyle
    if [[ "$tool" == "checkstyle" ]]; then
        local wrapper_path="$OUTPUT_DIR/tools/checkstyle-wrapper.sh"
        fragment_content="${fragment_content//\{\{WRAPPER_PATH\}\}/$wrapper_path}"
    fi

    # Substitute tool path
    fragment_content="${fragment_content//\{\{TOOL_PATH\}\}/$tool_path}"

    # Add language section if not exists
    if ! grep -q "^  $language:" "$OUTPUT_FILE"; then
        echo "" >> "$OUTPUT_FILE"
        echo "  $language:" >> "$OUTPUT_FILE"
    fi

    # Append fragment with proper indentation
    echo "$fragment_content" | sed 's/^/    /' >> "$OUTPUT_FILE"
}

# Function to handle formatter chaining
chain_formatters() {
    local language="$1"
    shift
    local formatters=("$@")

    if [[ ${#formatters[@]} -eq 0 ]]; then
        return
    fi

    # Build chained command
    local chained_cmd=""
    for formatter in "${formatters[@]}"; do
        local tool_path="${TOOL_PATHS[$formatter]:-}"
        if [[ -z "$tool_path" ]]; then
            continue
        fi

        if [[ -z "$chained_cmd" ]]; then
            # First formatter reads from stdin
            if [[ "$formatter" == "eslint" ]]; then
                chained_cmd="$tool_path --fix --stdin --stdin-filename \${INPUT}"
            elif [[ "$formatter" == "prettier" ]]; then
                chained_cmd="$tool_path --stdin-filepath \${INPUT}"
            elif [[ "$formatter" == "biome" ]]; then
                chained_cmd="$tool_path format --stdin-file-path=\${INPUT}"
            else
                chained_cmd="$tool_path"
            fi
        else
            # Subsequent formatters receive from pipe
            if [[ "$formatter" == "prettier" ]]; then
                chained_cmd="$chained_cmd | $tool_path --stdin-filepath \${INPUT}"
            elif [[ "$formatter" == "biome" ]]; then
                chained_cmd="$chained_cmd | $tool_path format --stdin-file-path=\${INPUT}"
            else
                chained_cmd="$chained_cmd | $tool_path"
            fi
        fi
    done

    # Write chained format command
    if [[ -n "$chained_cmd" ]]; then
        echo "    format-command: '$chained_cmd'" >> "$OUTPUT_FILE"
        echo "    format-stdin: true" >> "$OUTPUT_FILE"
    fi
}

# Load overrides if they exist
load_overrides() {
    local overrides_file="$OUTPUT_DIR/overrides.yaml"
    if [[ -f "$overrides_file" ]]; then
        # TODO: Implement override merging
        echo "Info: overrides.yaml found, but merging not yet implemented" >&2
    fi
}

# Main generation flow
main() {
    # Parse tools by language
    declare -A LANGS_TOOLS

    if command -v jq >/dev/null 2>&1; then
        # Group tools by language
        while IFS="=" read -r tool language; do
            if [[ -n "$tool" && -n "$language" ]]; then
                if [[ -z "${LANGS_TOOLS[$language]:-}" ]]; then
                    LANGS_TOOLS[$language]="$tool"
                else
                    LANGS_TOOLS[$language]="${LANGS_TOOLS[$language]} $tool"
                fi
            fi
        done < <(echo "$TOOLS_JSON" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' 2>/dev/null || true)
    fi

    # Process each language
    for language in "${!LANGS_TOOLS[@]}"; do
        local tools=(${LANGS_TOOLS[$language]})

        # Separate linters and formatters
        local linters=()
        local formatters=()

        for tool in "${tools[@]}"; do
            case "$tool" in
                eslint|ruff|golangci-lint|checkstyle|mypy)
                    linters+=("$tool")
                    ;;
                prettier|black|biome|gofmt)
                    formatters+=("$tool")
                    ;;
            esac
        done

        # Add linters first
        for linter in "${linters[@]}"; do
            append_tool_fragment "$linter" "$language"
        done

        # Handle formatter chaining
        if [[ ${#formatters[@]} -gt 1 ]]; then
            # Multiple formatters - chain them
            chain_formatters "$language" "${formatters[@]}"
        elif [[ ${#formatters[@]} -eq 1 ]]; then
            # Single formatter - use fragment
            append_tool_fragment "${formatters[0]}" "$language"
        fi
    done

    # Load and merge overrides
    load_overrides

    echo "Generated config at: $OUTPUT_FILE"
}

main
