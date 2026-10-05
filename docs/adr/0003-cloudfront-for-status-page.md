# 3. CloudFront for the status page

Status: Accepted

## Context

The status page must be public. Serving it directly from a public S3 bucket would weaken the rule that buckets never allow public access.

## Decision

The page is stored in a private S3 bucket with Block Public Access enabled and served through CloudFront using Origin Access Control. HTTPS uses CloudFront's default certificate.

## Consequences

- The bucket is never public. Only the CloudFront distribution can read it.
- Usage stays within CloudFront's always-free allowance at this scale.
- No custom domain, which avoids a Route 53 hosted zone charge.
- Distribution changes take several minutes to deploy.