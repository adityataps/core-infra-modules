#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# create_module.sh — scaffold a new Terraform module in the registry
# ---------------------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULES_DIR="$REPO_ROOT/modules"

# ── colours ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── helpers ─────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
${BOLD}Usage:${RESET}
  $(basename "$0") [OPTIONS]

${BOLD}Options:${RESET}
  -p, --provider      Cloud provider subfolder (e.g. aws, gcp)
  -n, --name          Module name in kebab-case (e.g. s3-static-site)
  -t, --title         Human-readable display name (e.g. "S3 Static Site")
  -d, --description   Short description of what the module provisions
  -h, --help          Show this help message

If any option is omitted you will be prompted for it interactively.

${BOLD}Example:${RESET}
  $(basename "$0") -p aws -n s3-static-site -t "S3 Static Site" -d "Hosts a static website on S3 with public access"
EOF
}

die() { echo -e "${RED}Error:${RESET} $*" >&2; exit 1; }

prompt() {
  local var_name="$1"
  local prompt_text="$2"
  local value
  read -r -p "$(echo -e "${CYAN}${prompt_text}:${RESET} ")" value
  [[ -z "$value" ]] && die "$var_name cannot be empty."
  echo "$value"
}

validate_name() {
  [[ "$1" =~ ^[a-z][a-z0-9-]*$ ]] || die "Module name must be kebab-case (lowercase letters, digits, hyphens) and start with a letter. Got: '$1'"
}

# ── argument parsing ────────────────────────────────────────────────────────
PROVIDER=""
NAME=""
TITLE=""
DESCRIPTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--provider)    PROVIDER="$2";    shift 2 ;;
    -n|--name)        NAME="$2";        shift 2 ;;
    -t|--title)       TITLE="$2";       shift 2 ;;
    -d|--description) DESCRIPTION="$2"; shift 2 ;;
    -h|--help)        usage; exit 0 ;;
    *) die "Unknown option: $1. Run with --help for usage." ;;
  esac
done

# ── interactive prompts for missing values ──────────────────────────────────
echo ""
echo -e "${BOLD}=== Create a new Terraform module ===${RESET}"
echo ""

[[ -z "$PROVIDER" ]]     && PROVIDER="$(prompt "provider" "Cloud provider (e.g. aws, gcp)")"
[[ -z "$NAME" ]]         && NAME="$(prompt "name" "Module name in kebab-case (e.g. s3-static-site)")"
[[ -z "$TITLE" ]]        && TITLE="$(prompt "title" "Display name (e.g. S3 Static Site)")"
[[ -z "$DESCRIPTION" ]]  && DESCRIPTION="$(prompt "description" "Short description")"

# ── validation ──────────────────────────────────────────────────────────────
PROVIDER="$(echo "$PROVIDER" | tr '[:upper:]' '[:lower:]')"
NAME="$(echo "$NAME" | tr '[:upper:]' '[:lower:]')"

validate_name "$NAME"
validate_name "$PROVIDER"

MODULE_DIR="$MODULES_DIR/$PROVIDER/$NAME"

[[ -d "$MODULE_DIR" ]] && die "Module already exists at: $MODULE_DIR"

# ── scaffold ─────────────────────────────────────────────────────────────────
mkdir -p "$MODULE_DIR"

# main.tf
cat > "$MODULE_DIR/main.tf" <<TFEOF
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # TODO: pin the provider version
    # $PROVIDER = {
    #   source  = "hashicorp/$PROVIDER"
    #   version = "~> X.Y"
    # }
  }
}

# ---------------------------------------------------------------------------
# $TITLE
# $DESCRIPTION
# ---------------------------------------------------------------------------
TFEOF

# variables.tf
cat > "$MODULE_DIR/variables.tf" <<TFEOF
# ---------------------------------------------------------------------------
# Input variables for the $TITLE module
# ---------------------------------------------------------------------------
TFEOF

# outputs.tf
cat > "$MODULE_DIR/outputs.tf" <<TFEOF
# ---------------------------------------------------------------------------
# Outputs for the $TITLE module
# ---------------------------------------------------------------------------
TFEOF

# README.md
cat > "$MODULE_DIR/README.md" <<MDEOF
# $TITLE

$DESCRIPTION

## Usage

\`\`\`hcl
module "$NAME" {
  source = "../../modules/$PROVIDER/$NAME"

  # TODO: add required variables
}
\`\`\`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|

## Outputs

| Name | Description |
|------|-------------|
MDEOF

# ── done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Module scaffolded successfully!${RESET}"
echo ""
echo -e "  ${BOLD}Provider:${RESET}    $PROVIDER"
echo -e "  ${BOLD}Name:${RESET}        $NAME"
echo -e "  ${BOLD}Title:${RESET}       $TITLE"
echo -e "  ${BOLD}Location:${RESET}    modules/$PROVIDER/$NAME/"
echo ""
echo -e "Files created:"
for f in main.tf variables.tf outputs.tf README.md; do
  echo "  modules/$PROVIDER/$NAME/$f"
done
echo ""
