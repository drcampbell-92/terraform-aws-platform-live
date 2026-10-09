# Runbook

How to handle the problems this platform is most likely to hit. Each entry covers the symptom, the cause, and the fix.

## A plan or apply fails with "Error acquiring the state lock"

**Cause:** another run holds the lock, or a run crashed and left the lock behind.

**Fix:**

1. Check the Actions tab for a `terraform` or `drift` run still in progress. If one is running, wait for it to finish.
2. If nothing is running, the lock is stale. The error message shows its lock ID.
3. From your computer, in the environment's folder, run `terraform force-unlock <lock-id>` and confirm.

Never force-unlock while a run is active. Two runs writing at once can corrupt state.

## An apply fails partway through

**Cause:** an error stopped the apply after some resources were already changed. Terraform does not roll back, and the changed resources are already recorded in state.

**Fix:**

1. Read the first error in the Apply step. Later errors are often side effects of the first.
2. Fix the cause in a pull request. The plan on that pull request shows what is left to do.
3. Merge it. The next apply continues from where the failed one stopped.

## A pipeline step fails with "AccessDenied" naming an action

**Cause:** the plan or apply role is missing a permission. The roles' policies are written by hand, so a module change can need an action they do not grant.

**Fix:**

1. Copy the action name from the error, for example `lambda:GetFunctionCodeSigningConfig`.
2. Add it to the matching statement in `bootstrap/policies.tf`, keeping the resource scoped to the environment prefix.
3. From your computer, in `bootstrap/`, run `terraform plan`, confirm only the role policies change, then run `terraform apply`.
4. Commit the change through a pull request, then re-run the failed workflow.

Add the narrowest action that fixes the error. Do not replace a statement with a wildcard.

## A workflow fails with "Not authorized to perform sts:AssumeRoleWithWebIdentity"

**Cause:** the request did not match the role's trust policy. AWS deliberately does not say which part.

**Fix:**

1. In the CloudTrail console, open Event history and filter by event name `AssumeRoleWithWebIdentity`.
2. Open the failed event. `userIdentity.userName` is the token's `sub` claim, and the resources list shows the role requested.
3. Compare them with the role's trust policy: `aws iam get-role --role-name <role> --query "Role.AssumeRolePolicyDocument"`.
4. Fix the mismatch in `bootstrap/` and apply it from your computer.

Common causes: a wrong `AWS_ACCOUNT_ID` secret, a job missing its `environment:` line, or a `sub` format that does not match.

## A "Drift detected" issue opens

**Cause:** something in AWS was changed outside Terraform, usually in the console.

**Fix:**

1. Open the workflow run linked in the issue and read the Plan step to see what differs.
2. Decide which side is right:
   - **The change was a mistake:** undo it in AWS, or redeploy from the code.
   - **The change was intentional:** update the code in a pull request so it matches.
3. The next drift run closes the issue automatically. To confirm sooner, run the `drift` workflow by hand.

Never leave drift unresolved. The next deploy would silently undo the change.

## A module release breaks an environment

**Cause:** a new module version behaves differently than expected.

**Fix:**

1. In a pull request, change the environment's four `source` lines back to the previous tag, for example from `?ref=v1.1.0` to `?ref=v1.0.1`.
2. Read the plan to confirm it reverses only the release's changes.
3. Merge it, and approve if it is prod.
4. Fix the module in the module repository and release a new version.

Because prod only runs tags that dev has already run, a bad release should be caught in dev first.

## A promotion runs but nothing changes

**Cause:** the code being deployed is not the code you expected. Usually the release tag points at an older commit.

**Fix:**

1. In the module repository, run `git log --oneline -1 <tag>` and `git show <tag>:<path>` to see what the tag contains.
2. Compare with `origin/main`.
3. Run `git pull` and check the top commit with `git log --oneline -1` before tagging again.

A plan showing no changes after a fix is the warning sign. Stop and check before approving anything else.

## Teardown

Order matters. The pipeline roles and the state bucket must outlive the environments they manage, and the state bucket must go last because it holds every other configuration's state.

1. **Disable the drift workflow.** In GitHub, open Actions, then `drift`, then the menu, then Disable workflow. Otherwise it fails every night once the roles are gone.
2. **Destroy prod.** From your computer, in `envs/prod`, with your `backend.hcl` and `terraform.tfvars` in place, run `terraform init -backend-config=backend.hcl`, then `terraform destroy`. CloudFront takes several minutes to disable and delete.
3. **Destroy dev.** Repeat in `envs/dev`.
4. **Destroy the bootstrap.** In `bootstrap/`, run `terraform destroy`. This removes the OIDC provider and the pipeline roles.
5. **Destroy the state bucket.** It lives in the `terraform-aws-remote-state-modules` repository's `bootstrap/` folder and is protected by `prevent_destroy`. Remove the `lifecycle` block, add `force_destroy = true` to the bucket so its stored versions are deleted too, run `terraform apply`, then `terraform destroy`.
6. **Verify.** In the AWS console, open Resource Groups, then Tag Editor, and search all regions for the tag `Project = uptime-platform`. Nothing should be listed. Check the Billing console over the next few days.
7. **Optional cleanup in GitHub:** delete the `dev` and `prod` environments and the repository secrets.
