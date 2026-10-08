# 5. Bootstrap owns pipeline identity

Status: Accepted

## Context

The pipeline needs AWS roles to plan and apply. A pipeline able to change its own roles, or the permissions boundary that caps the roles it creates, could grant itself unlimited access.

## Decision

- A separate `bootstrap` configuration, applied by an administrator, creates the GitHub OIDC provider and the plan and apply roles. The pipeline never applies it.
- Pipeline roles are named `github-uptime-<env>-<action>`, outside the `uptime-<env>-*` prefix that apply roles may manage.
- Apply roles can create roles only when they carry the workload boundary, cannot remove a boundary, and cannot change the boundary policy.
- `iam:PassRole` is limited to Lambda and EventBridge Scheduler.
- The prod apply role trusts only jobs in the protected prod GitHub Environment.

## Consequences

- Changes to pipeline permissions or the boundary require an administrator, outside the pipeline.
- CloudFront distributions and origin access controls get random IDs, so their permissions use `Resource = "*"`. This is an accepted gap.
- The policies are written by hand, so missing actions will surface as `AccessDenied` errors and be added one at a time.