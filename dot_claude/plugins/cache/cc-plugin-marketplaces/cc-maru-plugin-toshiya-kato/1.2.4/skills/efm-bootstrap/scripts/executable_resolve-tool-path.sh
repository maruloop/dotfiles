#!/usr/bin/env bash
set -euo pipefail

# resolve-tool-path.sh - Resolve the path to a linting/formatting tool
# Usage: ./resolve-tool-path.sh <tool_name> <language> <project_root>

TOOL_NAME="${1:-}"
LANGUAGE="${2:-}"
PROJECT_ROOT="${3:-.}"

if [[ -z "$TOOL_NAME" ]]; then
    echo "Error: tool_name is required" >&2
    exit 1
fi

cd "$PROJECT_ROOT"

# Parse .env file for environment variables if it exists
load_env_file() {
    if [[ -f ".env" ]]; then
        set -a
        source .env 2>/dev/null || true
        set +a
    fi
}

# Check project-local Node.js binaries
check_node_local() {
    local bin_path="node_modules/.bin/$TOOL_NAME"
    if [[ -x "$bin_path" ]]; then
        echo "$PROJECT_ROOT/$bin_path"
        return 0
    fi
    return 1
}

# Check package manager execution
check_package_manager() {
    # Detect package manager
    local pm=""
    if [[ -f "pnpm-lock.yaml" ]]; then
        pm="pnpm"
    elif [[ -f "yarn.lock" ]]; then
        pm="yarn"
    elif [[ -f "bun.lockb" ]]; then
        pm="bun"
    elif [[ -f "package.json" ]]; then
        pm="npm"
    fi

    if [[ -n "$pm" ]] && command -v "$pm" >/dev/null 2>&1; then
        # Return command that uses package manager
        echo "$pm exec $TOOL_NAME"
        return 0
    fi
    return 1
}

# Check Python virtual environment
check_python_venv() {
    local venv_paths=(".venv" "venv" ".virtualenv")

    for venv_path in "${venv_paths[@]}"; do
        if [[ -d "$venv_path/bin" ]]; then
            local tool_path="$venv_path/bin/$TOOL_NAME"
            if [[ -x "$tool_path" ]]; then
                echo "$PROJECT_ROOT/$tool_path"
                return 0
            fi
        fi
    done

    # Check if poetry is used
    if [[ -f "pyproject.toml" ]] && command -v poetry >/dev/null 2>&1; then
        echo "poetry run $TOOL_NAME"
        return 0
    fi

    return 1
}

# Check Gradle wrapper
check_gradle_wrapper() {
    if [[ "$TOOL_NAME" == "checkstyle" ]]; then
        if [[ -x "./gradlew" ]]; then
            echo "./gradlew checkstyleMain"
            return 0
        fi
    fi
    return 1
}

# Check system-installed binary
check_system() {
    if command -v "$TOOL_NAME" >/dev/null 2>&1; then
        command -v "$TOOL_NAME"
        return 0
    fi
    return 1
}

# Main resolution flow
main() {
    load_env_file

    local resolved_path=""

    # Priority order based on language
    case "$LANGUAGE" in
        javascript|typescript)
            if resolved_path=$(check_node_local); then
                echo "$resolved_path"
                exit 0
            fi
            if resolved_path=$(check_package_manager); then
                echo "$resolved_path"
                exit 0
            fi
            ;;
        python)
            if resolved_path=$(check_python_venv); then
                echo "$resolved_path"
                exit 0
            fi
            ;;
        java)
            if resolved_path=$(check_gradle_wrapper); then
                echo "$resolved_path"
                exit 0
            fi
            ;;
    esac

    # Fallback to system
    if resolved_path=$(check_system); then
        echo "$resolved_path"
        exit 0
    fi

    # Not found
    echo "Error: Tool '$TOOL_NAME' not found" >&2
    exit 1
}

main
