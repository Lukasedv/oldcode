# OpenCode COBOL Edition 🖥️

> The open source AI coding agent — **UN-MODERNIZED** to run on COBOL with GitHub Copilot SDK!

```
   ██████╗ ██████╗ ███████╗███╗   ██╗ ██████╗ ██████╗ ██████╗ ███████╗
  ██╔═══██╗██╔══██╗██╔════╝████╗  ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝
  ██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║     ██║   ██║██║  ██║█████╗  
  ╚██████╔╝██║     ███████╗██║ ╚████║╚██████╗╚██████╔╝██████╔╝███████╗
   ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝
```

## What is this?

This is OpenCode **un-modernized** from TypeScript/Bun to **COBOL** — the Common Business Oriented Language from 1959. It compiles and runs on Ubuntu using GnuCOBOL, and connects to GitHub Copilot via the official [@github/copilot-sdk](https://github.com/github/copilot-sdk) for AI-powered coding assistance!

## Requirements

- Ubuntu (or any Linux with GnuCOBOL)
- GnuCOBOL compiler
- Node.js 18+ (for Copilot SDK)
- GitHub Copilot CLI installed (`copilot` in PATH)

```bash
# Install GnuCOBOL
sudo apt install gnucobol

# Install Node.js if needed
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs

# Install Copilot CLI (see https://docs.github.com/en/copilot)
```

## Quick Start

```bash
# Build COBOL program
make

# Install Node.js dependencies for Copilot SDK
cd bridge && npm install && cd ..

# Run OpenCode COBOL Edition
./opencode
```

The Copilot SDK handles authentication automatically through the Copilot CLI.

## Commands

| Command  | Description |
|----------|-------------|
| `/help`  | Show help message |
| `/model` | Cycle through models (gpt-5 → gpt-5-mini → claude-sonnet-4.5) |
| `/clear` | Clear chat history |
| `/quit`  | Exit application |

Type anything else to chat with the AI!

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    COBOL TUI (OPENCODE-TUI.cob)             │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐    │
│  │ SCREEN      │  │ WORKING      │  │ PROCEDURE       │    │
│  │ SECTION     │  │ STORAGE      │  │ DIVISION        │    │
│  │ (Display)   │  │ (State)      │  │ (Logic)         │    │
│  └─────────────┘  └──────────────┘  └────────┬────────┘    │
│                                               │             │
│                                    CALL "SYSTEM"           │
└───────────────────────────────────────────────┬─────────────┘
                                                │
                                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    ai-bridge.sh (Shell wrapper)             │
└───────────────────────────────────────────────┬─────────────┘
                                                │
                                                ▼
┌─────────────────────────────────────────────────────────────┐
│              copilot-bridge.js (Node.js)                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           @github/copilot-sdk                        │   │
│  │  ┌──────────────┐  ┌──────────────────────────────┐ │   │
│  │  │ CopilotClient│  │ Session Management           │ │   │
│  │  │ (JSON-RPC)   │  │ (History, Events)            │ │   │
│  │  └──────────────┘  └──────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────┬─────────────┘
                                                │
                                                ▼
                         ┌──────────────────────────────────────┐
                         │         Copilot CLI (server)         │
                         │  ┌─────────┐ ┌─────────┐ ┌────────┐ │
                         │  │ gpt-5   │ │gpt-5-mini│ │claude  │ │
                         │  │         │ │         │ │sonnet  │ │
                         │  └─────────┘ └─────────┘ └────────┘ │
                         └──────────────────────────────────────┘
```

## Directory Structure

```
cobol/
├── SOURCE/              # COBOL source files (.cob)
│   └── OPENCODE-TUI.cob # Main TUI program
├── COPYBOOK/            # Shared data definitions (.cpy)
├── bridge/              # Node.js Copilot SDK bridge
│   ├── copilot-bridge.js
│   └── package.json
├── ai-bridge.sh         # Shell wrapper for COBOL→Node.js
├── Makefile             # Build system
├── opencode             # Launcher script
└── README.md            # This file
```

## Building

```bash
make        # Build COBOL program
make clean  # Clean build artifacts
```

## Technical Details

- **Language**: COBOL-85
- **Compiler**: GnuCOBOL 3.1.2
- **UI**: SCREEN SECTION with ACCEPT/DISPLAY
- **AI Integration**: Official GitHub Copilot SDK via Node.js bridge
- **Models**: gpt-5, gpt-5-mini, claude-sonnet-4.5

## Why COBOL?

Because sometimes you need to PERFORM UNTIL END-OF-TASK.

---

*"Did you know? 95% of ATM transactions still use COBOL!"*
