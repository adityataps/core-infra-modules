#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# setup_hooks.sh — install pre-commit hooks and verify required tooling
# ---------------------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/lib/helpers.sh
source "$REPO_ROOT/scripts/lib/helpers.sh"

# ── script-local helpers ──────────────────────────────────────────────────────
info() { echo -e "  ${BOLD}...${RESET}     $*"; }

# ── pre-flight checks ────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}=== Setting up git hooks ===${RESET}"
echo ""

info "Checking required tools..."
echo ""

check_tool "pre-commit"      "brew install pre-commit"
check_tool "terraform-docs"  "brew install terraform-docs"
check_tool "terraform"       "brew install hashicorp/tap/terraform"

echo ""

# ── install hooks ─────────────────────────────────────────────────────────────
info "Installing pre-commit hooks into .git/hooks/..."
cd "$REPO_ROOT"
pre-commit install
echo ""

ok "Hooks installed. They will run automatically on every commit."
echo ""
echo -e "  ${BOLD}Tip:${RESET} run ${BOLD}pre-commit run --all-files${RESET} to apply hooks to the whole repo now."
echo ""
