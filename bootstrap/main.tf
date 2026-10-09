data "aws_caller_identity" "current" {}

locals {
  account_id     = data.aws_caller_identity.current.account_id
  state_bucket   = "tfstate-${local.account_id}-us-east-1"
  environments   = toset(["dev", "prod"])
  subject_prefix = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "plan" {
  for_each = local.environments

  name                 = "github-uptime-${each.key}-plan"
  description          = "Read-only role GitHub Actions uses to plan the ${each.key} environment"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "${local.subject_prefix}:pull_request"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "plan" {
  for_each = local.environments

  name = "plan-${each.key}"
  role = aws_iam_role.plan[each.key].id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.read_statements[each.key]
  })
}

resource "aws_iam_role" "apply" {
  for_each = local.environments

  name                 = "github-uptime-${each.key}-apply"
  description          = "Role GitHub Actions uses to apply the ${each.key} environment"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "${local.subject_prefix}:environment:${each.key}"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "apply" {
  for_each = local.environments

  name = "apply-${each.key}"
  role = aws_iam_role.apply[each.key].id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = concat(local.read_statements[each.key], local.write_statements[each.key])
  })
}