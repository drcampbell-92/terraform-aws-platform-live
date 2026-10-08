# Platform standards

## Naming

Resources are named `uptime-<environment>-<component>`, for example `uptime-dev-checker`.

## Required tags

Every resource carries these tags, applied through provider `default_tags`.

| Tag | Example | Purpose |
|---|---|---|
| `Project` | `uptime-platform` | Groups all platform resources |
| `Environment` | `dev`, `prod`, or `shared` | Separates environments for cost and access; `shared` is for bootstrap resources |
| `Owner` | `platform-team` | Who to contact |
| `ManagedBy` | `terraform` | Signals that console changes will be overwritten |
| `Repository` | `terraform-aws-platform-live` | Where the code lives |

## State

State lives in the existing S3 state bucket, one key per environment:

- `platform/dev/terraform.tfstate`
- `platform/prod/terraform.tfstate`
- `platform/bootstrap/terraform.tfstate`

## Environments

| | Dev | Prod |
|---|---|---|
| Deploys | Automatically on merge | After manual approval |
| Module versions | May adopt a new tag first | Only tags already running in dev |