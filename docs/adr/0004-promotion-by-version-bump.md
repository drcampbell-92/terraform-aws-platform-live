# 4. Promotion by version bump

Status: Accepted

## Context

Production should only run module versions that have already run successfully in dev.

## Decision

A new module tag is adopted in dev first. Production is upgraded only by a pull request that changes its pinned tag, and the prod apply requires manual approval.

## Consequences

- Every production change has a reviewed pull request and an approval record.
- Upgrades take two steps instead of one.