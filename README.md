# core-infra-modules

Reusable Terraform modules for AWS and GCP personal cloud environments.

## Getting started

After cloning, install the git hooks and verify required tooling:

```bash
./scripts/setup_hooks.sh
```

This checks that `pre-commit`, `terraform-docs`, and `terraform` are available, then wires up the pre-commit hooks. Required tools can be installed via Homebrew:

```bash
brew install pre-commit terraform-docs hashicorp/tap/terraform
```

## Scripts

| Script | Purpose |
|---|---|
| `scripts/setup_hooks.sh` | Install pre-commit hooks and verify required tooling |
| `scripts/create_module.sh` | Scaffold a new module directory |

## Repository layout

```
modules/
  aws/        # AWS Terraform modules
  gcp/        # GCP Terraform modules
scripts/
  setup_hooks.sh     # Install pre-commit hooks locally
  create_module.sh   # Scaffold a new module directory
```

Each module lives under `modules/<provider>/<module-name>/` and is self-contained with its own `main.tf`, `variables.tf`, `outputs.tf`, `locals.tf`, `versions.tf`, `tests/`, `examples/`, and `README.md`.

## Common commands

```bash
# Install hooks (run once after cloning)
./scripts/setup_hooks.sh

# Scaffold a new module
./scripts/create_module.sh -p aws -n my-module -t "My Module" -d "What it does"

# Format all Terraform files
terraform fmt -recursive

# Validate a specific module
terraform -chdir=modules/aws/<module-name> validate

# Run all pre-commit hooks against the whole repo
pre-commit run --all-files
```
