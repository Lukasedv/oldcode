# OpenCode COBOL Edition 🖥️

> The open source AI coding agent — **UN-MODERNIZED** to run on COBOL.

```
   ██████╗ ██████╗ ███████╗███╗   ██╗ ██████╗ ██████╗ ██████╗ ███████╗
  ██╔═══██╗██╔══██╗██╔════╝████╗  ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝
  ██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║     ██║   ██║██║  ██║█████╗  
  ╚██████╔╝██║     ███████╗██║ ╚████║╚██████╗╚██████╔╝██████╔╝███████╗
   ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝
```

## What is this?

This is OpenCode **un-modernized** from TypeScript/Bun to **COBOL** — the Common Business Oriented Language from 1959. It compiles and runs on Ubuntu using GnuCOBOL.

## Requirements

- Ubuntu (or any Linux with GnuCOBOL)
- GnuCOBOL compiler

```bash
sudo apt install gnucobol
```

## Building

```bash
make        # Build all programs
make clean  # Clean build artifacts
```

## Running

```bash
./opencode      # Run with splash screen
./bin/OPENCODE-TUI  # Run directly
```

## Commands

| Command  | Description |
|----------|-------------|
| `/help`  | Show help message |
| `/tab`   | Switch between BUILD and PLAN agents |
| `/clear` | Clear chat history |
| `/quit`  | Exit application |

Or just type to chat!

## Directory Structure

```
cobol/
├── SOURCE/          # COBOL source files (.cob)
├── COPYBOOK/        # Shared data definitions (.cpy)
├── OBJECT/          # Compiled objects
├── DATA/            # ISAM data files
├── bin/             # Compiled executables
├── Makefile         # Build system
├── opencode         # Launcher script
└── README.md        # This file
```

## Technical Details

- **Language**: COBOL-85/2002
- **Compiler**: GnuCOBOL 3.1.2
- **UI**: SCREEN SECTION with ACCEPT/DISPLAY
- **Format**: Fixed column format (traditional)

## Migration Progress

- [x] Phase 1: TUI scaffold
- [ ] Phase 2: Data layer (ISAM files)
- [ ] Phase 3: Core modules
- [ ] Phase 4: AI provider integration (curl)
- [ ] Phase 5: LSP support

## Why?

Because sometimes you need to PERFORM UNTIL END-OF-TASK.

---

*"Did you know? 95% of ATM transactions still use COBOL!"*
