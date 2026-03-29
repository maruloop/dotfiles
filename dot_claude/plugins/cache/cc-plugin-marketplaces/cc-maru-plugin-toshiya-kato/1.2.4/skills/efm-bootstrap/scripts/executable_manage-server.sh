#!/usr/bin/env bash
set -euo pipefail

# manage-server.sh - Manage EFM server lifecycle
# Usage: ./manage-server.sh <action> <project_root>
# Actions: start, stop, restart, status

ACTION="${1:-}"
PROJECT_ROOT="${2:-.}"

if [[ -z "$ACTION" ]]; then
    echo "Error: action required (start|stop|restart|status)" >&2
    exit 1
fi

cd "$PROJECT_ROOT"

PID_FILE=".claude/efm/efm.pid"
LOG_FILE=".claude/efm/efm.log"
CONFIG_FILE=".claude/efm/config.yaml"
START_SCRIPT=".claude/efm/start.sh"

# Check if efm-langserver is installed
check_efm_binary() {
    if ! command -v efm-langserver >/dev/null 2>&1; then
        echo "Error: efm-langserver not found"
        echo ""
        echo "Install with:"
        echo "  go install github.com/mattn/efm-langserver@latest"
        echo ""
        echo "Make sure \$GOPATH/bin is in your PATH"
        exit 1
    fi
}

# Check if server is running
is_running() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Generate start script
generate_start_script() {
    mkdir -p "$(dirname "$START_SCRIPT")"

    cat > "$START_SCRIPT" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="{{PROJECT_ROOT}}"
cd "$PROJECT_ROOT"

CONFIG_FILE=".claude/efm/config.yaml"
LOG_FILE=".claude/efm/efm.log"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found at $CONFIG_FILE" >&2
    exit 1
fi

# Start efm-langserver
efm-langserver -c "$CONFIG_FILE" 2>&1 | tee -a "$LOG_FILE"
EOF

    # Substitute project root
    sed -i.bak "s|{{PROJECT_ROOT}}|$PROJECT_ROOT|g" "$START_SCRIPT"
    rm -f "$START_SCRIPT.bak"

    chmod +x "$START_SCRIPT"
}

# Start server with auto-restart
start_server() {
    check_efm_binary

    if is_running; then
        echo "EFM server is already running (PID: $(cat "$PID_FILE"))"
        return 0
    fi

    # Validate config first
    if [[ -f "$(dirname "$0")/validate-efm.sh" ]]; then
        if ! "$(dirname "$0")/validate-efm.sh" "$PROJECT_ROOT"; then
            echo "Error: Config validation failed" >&2
            exit 1
        fi
    fi

    # Generate start script
    generate_start_script

    # Start server in background
    echo "Starting EFM server..."
    mkdir -p "$(dirname "$LOG_FILE")"

    # Launch with auto-restart wrapper
    (
        local retry_count=0
        local max_retries=5
        local backoff_seconds=1

        while [[ $retry_count -lt $max_retries ]]; do
            # Start server
            "$START_SCRIPT" &
            local pid=$!
            echo "$pid" > "$PID_FILE"

            # Wait for process
            wait $pid || true

            # Check if intentional stop
            if [[ ! -f "$PID_FILE" ]]; then
                echo "Server stopped intentionally" >> "$LOG_FILE"
                break
            fi

            # Crashed - retry with backoff
            retry_count=$((retry_count + 1))
            if [[ $retry_count -lt $max_retries ]]; then
                echo "Server crashed, restarting in ${backoff_seconds}s (attempt $retry_count/$max_retries)..." >> "$LOG_FILE"
                sleep $backoff_seconds
                backoff_seconds=$((backoff_seconds * 2))
            else
                echo "Server crashed $max_retries times, giving up" >> "$LOG_FILE"
                rm -f "$PID_FILE"
                break
            fi
        done
    ) &

    # Wait a moment for startup
    sleep 1

    if is_running; then
        echo "EFM server started (PID: $(cat "$PID_FILE"))"
        echo "Logs: $PROJECT_ROOT/$LOG_FILE"
    else
        echo "Error: Failed to start EFM server. Check logs at $LOG_FILE" >&2
        exit 1
    fi
}

# Stop server
stop_server() {
    if ! is_running; then
        echo "EFM server is not running"
        rm -f "$PID_FILE"
        return 0
    fi

    local pid
    pid=$(cat "$PID_FILE")
    echo "Stopping EFM server (PID: $pid)..."

    # Send SIGTERM
    kill -TERM "$pid" 2>/dev/null || true

    # Wait for graceful shutdown (up to 10 seconds)
    local wait_count=0
    while kill -0 "$pid" 2>/dev/null && [[ $wait_count -lt 10 ]]; do
        sleep 1
        wait_count=$((wait_count + 1))
    done

    # Force kill if still running
    if kill -0 "$pid" 2>/dev/null; then
        echo "Force killing server..."
        kill -KILL "$pid" 2>/dev/null || true
    fi

    rm -f "$PID_FILE"
    echo "EFM server stopped"
}

# Restart server
restart_server() {
    stop_server
    sleep 1
    start_server
}

# Show server status
show_status() {
    if is_running; then
        local pid
        pid=$(cat "$PID_FILE")
        echo "EFM server is running (PID: $pid)"

        # Show recent log entries
        if [[ -f "$LOG_FILE" ]]; then
            echo ""
            echo "Recent log entries:"
            tail -n 5 "$LOG_FILE" | sed 's/^/  /'
        fi
    else
        echo "EFM server is not running"
        if [[ -f "$PID_FILE" ]]; then
            echo "(stale PID file found)"
            rm -f "$PID_FILE"
        fi
    fi
}

# Main dispatcher
case "$ACTION" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    restart)
        restart_server
        ;;
    status)
        show_status
        ;;
    *)
        echo "Error: Unknown action '$ACTION'" >&2
        echo "Usage: $0 <start|stop|restart|status> <project_root>" >&2
        exit 1
        ;;
esac
