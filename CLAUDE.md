# core-infra-modules

Personal IaC module registry — reusable Terraform modules for AWS and GCP personal cloud environments.

## Repository layout

```
modules/
  aws/        # AWS Terraform modules
  gcp/        # GCP Terraform modules
scripts/
  create_module.sh   # Scaffolds a new module directory
```

Each module lives under `modules/<provider>/<module-name>/` and should be self-contained with its own `variables.tf`, `outputs.tf`, `main.tf`, and `README.md`.

## Conventions

- **Provider directories**: `aws` and `gcp` are the only top-level providers under `modules/`.
- **Module structure**: Every module must have at minimum `main.tf`, `variables.tf`, and `outputs.tf`. A `README.md` per module is expected.
- **Naming**: Module directories use kebab-case (e.g., `s3-static-site`, `gcs-bucket`).
- **No hardcoded values**: All environment-specific values (account IDs, regions, project IDs) must be exposed as variables with sensible defaults where appropriate.
- **No secrets in code**: `.tfvars` files are gitignored — never commit credentials or sensitive values.

## Terraform conventions

- Minimum Terraform version: specify in a `required_version` constraint in each module's `terraform {}` block.
- Pin provider versions using `~>` (pessimistic constraint) in `required_providers`.
- Use `terraform fmt` before committing — all `.tf` files should be formatted.
- Validate modules with `terraform validate` before committing.

## Common commands

```bash
# Format all Terraform files
terraform fmt -recursive

# Validate a specific module
terraform -chdir=modules/aws/<module-name> validate

# Initialize a module (for local testing)
terraform -chdir=modules/aws/<module-name> init

# Scaffold a new module
./scripts/create_module.sh <provider> <module-name>
```

## What NOT to do

- Do not add a `provider` block inside modules — provider configuration belongs in the caller.
- Do not use `count` for resources that have distinct identities; prefer `for_each`.
- Do not commit `.terraform/`, `*.tfstate`, `*.tfvars`, or `crash.log` files (all gitignored).
- Do not create cross-provider dependencies between modules.
