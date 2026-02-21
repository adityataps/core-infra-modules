#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# create_module.sh — scaffold a new Terraform module in the registry
# ---------------------------------------------------------------------------

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULES_DIR="$REPO_ROOT/modules"

# shellcheck source=scripts/lib/helpers.sh
source "$REPO_ROOT/scripts/lib/helpers.sh"

# ── script-local helpers ──────────────────────────────────────────────────────
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

info()   { echo -e "  ${GREEN}create${RESET}  $*"; }

prompt() {
  local var_name="$1"
  local prompt_text="$2"
  local value
  read -r -p "$(echo -e "${CYAN}${prompt_text}:${RESET} ")" value
  [[ -z "$value" ]] && die "$var_name cannot be empty."
  echo "$value"
}

validate_name() {
  [[ "$1" =~ ^[a-z][a-z0-9-]*$ ]] || \
    die "Must be kebab-case (lowercase letters, digits, hyphens), starting with a letter. Got: '$1'"
}

# ── argument parsing ──────────────────────────────────────────────────────────
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

# ── interactive prompts for missing values ────────────────────────────────────
echo ""
echo -e "${BOLD}=== Create a new Terraform module ===${RESET}"
echo ""

[[ -z "$PROVIDER" ]]    && PROVIDER="$(prompt "provider" "Cloud provider (e.g. aws, gcp)")"
[[ -z "$NAME" ]]        && NAME="$(prompt "name" "Module name in kebab-case (e.g. s3-static-site)")"
[[ -z "$TITLE" ]]       && TITLE="$(prompt "title" "Display name (e.g. S3 Static Site)")"
[[ -z "$DESCRIPTION" ]] && DESCRIPTION="$(prompt "description" "Short description")"

# ── validation ────────────────────────────────────────────────────────────────
PROVIDER="$(echo "$PROVIDER" | tr '[:upper:]' '[:lower:]')"
NAME="$(echo "$NAME" | tr '[:upper:]' '[:lower:]')"

validate_name "$PROVIDER"
validate_name "$NAME"

MODULE_DIR="$MODULES_DIR/$PROVIDER/$NAME"

[[ -d "$MODULE_DIR" ]] && die "Module already exists at: $MODULE_DIR"

# ── scaffold ──────────────────────────────────────────────────────────────────
mkdir -p "$MODULE_DIR"
mkdir -p "$MODULE_DIR/tests"
mkdir -p "$MODULE_DIR/examples/basic"

# ── versions.tf ───────────────────────────────────────────────────────────────
cat > "$MODULE_DIR/versions.tf" <<TFEOF
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # TODO: uncomment and pin the provider version
    # $PROVIDER = {
    #   source  = "hashicorp/$PROVIDER"
    #   version = "~> X.Y"
    # }
  }
}
TFEOF
info "$NAME/versions.tf"

# ── main.tf ───────────────────────────────────────────────────────────────────
cat > "$MODULE_DIR/main.tf" <<TFEOF
# ---------------------------------------------------------------------------
# $TITLE
# $DESCRIPTION
# ---------------------------------------------------------------------------
TFEOF
info "$NAME/main.tf"

# ── variables.tf ──────────────────────────────────────────────────────────────
cat > "$MODULE_DIR/variables.tf" <<TFEOF
# ---------------------------------------------------------------------------
# Input variables for the $TITLE module
# ---------------------------------------------------------------------------

# variable "example" {
#   description = "An example variable."
#   type        = string
# }
TFEOF
info "$NAME/variables.tf"

# ── outputs.tf ────────────────────────────────────────────────────────────────
cat > "$MODULE_DIR/outputs.tf" <<TFEOF
# ---------------------------------------------------------------------------
# Outputs for the $TITLE module
# ---------------------------------------------------------------------------

# output "example" {
#   description = "An example output."
#   value       = resource_type.example.id
# }
TFEOF
info "$NAME/outputs.tf"

# ── locals.tf ─────────────────────────────────────────────────────────────────
cat > "$MODULE_DIR/locals.tf" <<TFEOF
# ---------------------------------------------------------------------------
# Local values for the $TITLE module
# ---------------------------------------------------------------------------

locals {
  module_name = "$NAME"

  # common_tags = {
  #   module    = "$NAME"
  #   provider  = "$PROVIDER"
  #   managed   = "terraform"
  # }
}
TFEOF
info "$NAME/locals.tf"

# ── tests/<name>.tftest.hcl ───────────────────────────────────────────────────
cat > "$MODULE_DIR/tests/${NAME}.tftest.hcl" <<TFEOF
# ---------------------------------------------------------------------------
# Native Terraform tests for the $TITLE module
# Run with: terraform test
# Docs: https://developer.hashicorp.com/terraform/language/tests
# ---------------------------------------------------------------------------

# variables {
#   example = "test-value"
# }

# run "plan_succeeds" {
#   command = plan
#
#   assert {
#     condition     = <RESOURCE>.<NAME>.<ATTR> == "expected"
#     error_message = "Expected <ATTR> to equal 'expected'."
#   }
# }
TFEOF
info "$NAME/tests/${NAME}.tftest.hcl"

# ── examples/basic/versions.tf ───────────────────────────────────────────────
cat > "$MODULE_DIR/examples/basic/versions.tf" <<TFEOF
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # TODO: mirror provider pins from the module's versions.tf
    # $PROVIDER = {
    #   source  = "hashicorp/$PROVIDER"
    #   version = "~> X.Y"
    # }
  }
}
TFEOF
info "$NAME/examples/basic/versions.tf"

# ── examples/basic/main.tf ───────────────────────────────────────────────────
cat > "$MODULE_DIR/examples/basic/main.tf" <<TFEOF
# ---------------------------------------------------------------------------
# Basic example — $TITLE
# ---------------------------------------------------------------------------

module "$NAME" {
  source = "../../"

  # TODO: populate required variables
}
TFEOF
info "$NAME/examples/basic/main.tf"

# ── README.md ─────────────────────────────────────────────────────────────────
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

## Examples

- [Basic](./examples/basic/)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Testing

\`\`\`bash
terraform -chdir=modules/$PROVIDER/$NAME test
\`\`\`
MDEOF
info "$NAME/README.md"

# ── done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Module scaffolded successfully!${RESET}"
echo ""
echo -e "  ${BOLD}Provider:${RESET}    $PROVIDER"
echo -e "  ${BOLD}Name:${RESET}        $NAME"
echo -e "  ${BOLD}Title:${RESET}       $TITLE"
echo -e "  ${BOLD}Location:${RESET}    modules/$PROVIDER/$NAME/"
echo ""
