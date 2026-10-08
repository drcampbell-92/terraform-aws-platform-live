# 1. Separate module and live repositories

Status: Accepted

## Context

Product teams need reusable building blocks. A change to shared code must not reach production without review.

## Decision

Reusable modules live in `terraform-aws-platform-modules` and are released as Git tags such as `v1.0.0`. Environments live in `terraform-aws-platform-live` and pin an exact module tag.

## Consequences

- Promotion happens through a pull request that changes a pinned version.
- Rollback means pinning the previous tag.
- Two repositories must be maintained, and every module change needs a release.