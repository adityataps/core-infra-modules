#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# helpers.sh — shared utilities sourced by scripts in this repo
# Not intended to be executed directly.
# ---------------------------------------------------------------------------

# ── colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── logging ───────────────────────────────────────────────────────────────────
die()  { echo -e "${RED}Error:${RESET} $*" >&2; exit 1; }
ok()   { echo -e "  ${GREEN}ok${RESET}      $*"; }
warn() { echo -e "  ${YELLOW}warn${RESET}    $*"; }

# ── tool verification ─────────────────────────────────────────────────────────
# check_tool <cmd> <brew-install-hint>
# Prints the tool version on success, exits with an error on failure.
check_tool() {
  local cmd="$1"
  local install_hint="$2"
  if command -v "$cmd" &>/dev/null; then
    ok "$cmd $("$cmd" --version 2>&1 | head -1)"
  else
    die "'$cmd' not found. Install it with: $install_hint"
  fi
}
