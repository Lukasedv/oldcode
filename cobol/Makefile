# =========================================================================
# OPENCODE COBOL EDITION - BUILD SYSTEM
# =========================================================================
# Makefile for compiling COBOL programs with GnuCOBOL on Ubuntu
# =========================================================================

COBC = cobc
COBFLAGS = -x
SRCDIR = SOURCE
CPYDIR = COPYBOOK
BINDIR = bin
OBJDIR = OBJECT

# Find all COBOL source files
SOURCES = $(wildcard $(SRCDIR)/*.cob)
PROGRAMS = $(SOURCES:$(SRCDIR)/%.cob=$(BINDIR)/%)

# Default target
all: dirs $(PROGRAMS)
	@echo ""
	@echo "=========================================="
	@echo " OPENCODE COBOL BUILD COMPLETE"
	@echo "=========================================="
	@echo " Run with: ./bin/OPENCODE-TUI"
	@echo "=========================================="

# Create directories
dirs:
	@mkdir -p $(BINDIR) $(OBJDIR)

# Compile COBOL programs
$(BINDIR)/%: $(SRCDIR)/%.cob
	@echo "Compiling $<..."
	$(COBC) $(COBFLAGS) -I $(CPYDIR) -o $@ $<

# Run the main application
run: all
	@echo "Starting OpenCode COBOL Edition..."
	@./$(BINDIR)/OPENCODE-TUI

# Clean build artifacts
clean:
	rm -rf $(BINDIR)/* $(OBJDIR)/*
	@echo "Build artifacts cleaned."

# Show help
help:
	@echo "OpenCode COBOL Edition - Build Targets:"
	@echo "  make        - Build all programs"
	@echo "  make run    - Build and run main application"
	@echo "  make clean  - Remove build artifacts"
	@echo "  make help   - Show this help"

.PHONY: all dirs run clean help
