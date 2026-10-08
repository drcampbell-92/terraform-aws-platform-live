# 2. Least-privilege pipeline roles

Status: Accepted

## Context

Least privilege is the platform's first security rule. The pipeline needs AWS access, but long-lived access keys can leak and a single broad role would let any pull request change production.

## Decision

- GitHub Actions authenticates through OIDC. No access keys are stored.
- Each environment has two roles: a read-only plan role and an apply role.
- Apply roles are limited to the services and resource name prefixes the platform uses.
- The prod apply role trusts only workflows running in the protected prod GitHub Environment.

## Consequences

- More roles to define and maintain.
- Apply roles must create IAM roles for Lambda, which risks privilege escalation. A permissions boundary will cap what any created role can do.