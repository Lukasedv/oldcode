#!/bin/bash
# =========================================================================
# OPENCODE COBOL EDITION - GITHUB COPILOT BRIDGE
# =========================================================================
# Bridges COBOL TUI to GitHub Copilot via official SDK
# =========================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIDGE_DIR="$SCRIPT_DIR/bridge"
HISTORY_FILE="$SCRIPT_DIR/DATA/history.json"

# =========================================================================
# Chat via Copilot SDK
# =========================================================================

do_chat() {
    local model="${1:-gpt-5}"
    local message="$2"
    
    cd "$BRIDGE_DIR"
    node copilot-bridge.js chat "$message" "$model"
}

# =========================================================================
# History Management
# =========================================================================

clear_history() {
    cd "$BRIDGE_DIR"
    node copilot-bridge.js clear
}

# =========================================================================
# Status Check
# =========================================================================

do_status() {
    cd "$BRIDGE_DIR"
    node copilot-bridge.js status
}

# =========================================================================
# Main
# =========================================================================

main() {
    local cmd="$1"
    shift || true
    
    case "$cmd" in
        chat)
            do_chat "$@"
            ;;
        clear)
            clear_history
            ;;
        status)
            do_status
            ;;
        *)
            echo "Usage: ai-bridge.sh <chat|clear|status>"
            echo ""
            echo "  chat MODEL MSG     - Send message to Copilot"
            echo "  clear              - Clear conversation history"
            echo "  status             - Check connection status"
            echo ""
            echo "Models: gpt-5, gpt-5-mini, claude-sonnet-4.5, etc."
            ;;
    esac
}

main "$@"
