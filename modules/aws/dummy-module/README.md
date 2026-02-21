# Dummy Module

Dummy module for AWS.

## Usage

```hcl
module "dummy-module" {
  source = "../../modules/aws/dummy-module"

  # TODO: add required variables
}
```

## Examples

- [Basic](./examples/basic/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Testing

```bash
terraform -chdir=modules/aws/dummy-module test
```
