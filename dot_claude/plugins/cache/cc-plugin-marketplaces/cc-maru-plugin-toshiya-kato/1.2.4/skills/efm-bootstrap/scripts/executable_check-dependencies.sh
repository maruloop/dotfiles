#!/usr/bin/env bash
set -euo pipefail

# check-dependencies.sh - Check for required project dependencies
# Usage: ./check-dependencies.sh <project_root> <tools_json>

PROJECT_ROOT="${1:-.}"
TOOLS_JSON="${2:-{}}"

cd "$PROJECT_ROOT"

WARNINGS=()

# Check Node.js dependencies
check_node_dependencies() {
    if [[ -f "package.json" ]]; then
        if [[ ! -d "node_modules" ]]; then
            WARNINGS+=("⚠️  node_modules not found. Run 'npm install' or your package manager's install command.")
        fi
    fi
}

# Check Python dependencies
check_python_dependencies() {
    if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
        local venv_found=false
        for venv_path in ".venv" "venv" ".virtualenv"; do
            if [[ -d "$venv_path" ]]; then
                venv_found=true
                break
            fi
        done

        if [[ "$venv_found" == false ]]; then
            WARNINGS+=("⚠️  Python virtual environment not found. Consider creating one with 'python -m venv .venv'")
        fi
    fi
}

# Check for .env file for auth tokens
check_env_file() {
    # Parse tools that might need API keys
    local needs_env=false

    # Add more tools that need API keys as needed
    if echo "$TOOLS_JSON" | grep -q "custom-linter"; then
        needs_env=true
    fi

    if [[ "$needs_env" == true ]] && [[ ! -f ".env" ]]; then
        WARNINGS+=("⚠️  .env file not found. Some tools may require API keys or configuration.")
    fi
}

# Check if efm-langserver is installed
check_efm_binary() {
    if ! command -v efm-langserver >/dev/null 2>&1; then
        WARNINGS+=("❌ efm-langserver not found. Install with: go install github.com/mattn/efm-langserver@latest")
    fi
}

# Main check flow
main() {
    check_efm_binary
    check_node_dependencies
    check_python_dependencies
    check_env_file

    # Output warnings as JSON
    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo "{"
        echo "  \"hasWarnings\": true,"
        echo "  \"warnings\": ["
        for i in "${!WARNINGS[@]}"; do
            echo -n "    \"${WARNINGS[$i]}\""
            if [[ $i -lt $((${#WARNINGS[@]} - 1)) ]]; then
                echo ","
            else
                echo ""
            fi
        done
        echo "  ]"
        echo "}"
    else
        echo "{\"hasWarnings\": false, \"warnings\": []}"
    fi
}

main
