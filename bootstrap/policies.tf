locals {
  read_statements = {
    for env in local.environments : env => [
      {
        Sid      = "StateBucketList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::${local.state_bucket}"]
      },
      {
        Sid      = "StateRead"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::${local.state_bucket}/platform/${env}/terraform.tfstate"]
      },
      {
        Sid      = "StateLock"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = ["arn:aws:s3:::${local.state_bucket}/platform/${env}/terraform.tfstate.tflock"]
      },
      {
        Sid      = "ReadTables"
        Effect   = "Allow"
        Action   = ["dynamodb:Describe*", "dynamodb:List*"]
        Resource = ["arn:aws:dynamodb:*:${local.account_id}:table/uptime-${env}-*"]
      },
      {
        Sid      = "ReadFunctions"
        Effect   = "Allow"
        Action   = ["lambda:Get*", "lambda:List*"]
        Resource = ["arn:aws:lambda:*:${local.account_id}:function:uptime-${env}-*"]
      },
      {
        Sid      = "ReadSchedules"
        Effect   = "Allow"
        Action   = ["scheduler:GetSchedule", "scheduler:ListTagsForResource"]
        Resource = ["arn:aws:scheduler:*:${local.account_id}:schedule/default/uptime-${env}-*"]
      },
      {
        Sid      = "ReadLogGroups"
        Effect   = "Allow"
        Action   = ["logs:ListTagsForResource", "logs:ListTagsLogGroup"]
        Resource = ["arn:aws:logs:*:${local.account_id}:log-group:/aws/lambda/uptime-${env}-*"]
      },
      {
        Sid      = "DescribeLogGroups"
        Effect   = "Allow"
        Action   = ["logs:DescribeLogGroups"]
        Resource = ["*"]
      },
      {
        Sid      = "ReadTopics"
        Effect   = "Allow"
        Action   = ["sns:Get*", "sns:List*"]
        Resource = ["arn:aws:sns:*:${local.account_id}:uptime-${env}-*"]
      },
      {
        Sid      = "ReadStatusBucket"
        Effect   = "Allow"
        Action   = ["s3:Get*", "s3:List*"]
        Resource = ["arn:aws:s3:::uptime-${env}-status-*", "arn:aws:s3:::uptime-${env}-status-*/*"]
      },
      {
        Sid      = "ReadCloudFront"
        Effect   = "Allow"
        Action   = ["cloudfront:Get*", "cloudfront:List*"]
        Resource = ["*"]
      },
      {
        Sid      = "ReadBudgets"
        Effect   = "Allow"
        Action   = ["budgets:ViewBudget", "budgets:ListTagsForResource"]
        Resource = ["arn:aws:budgets::${local.account_id}:budget/uptime-${env}-*"]
      },
      {
        Sid      = "ReadWorkloadRoles"
        Effect   = "Allow"
        Action   = ["iam:GetRole", "iam:GetRolePolicy", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", "iam:ListRoleTags"]
        Resource = ["arn:aws:iam::${local.account_id}:role/uptime-${env}-*"]
      },
      {
        Sid      = "ReadBoundary"
        Effect   = "Allow"
        Action   = ["iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicyVersions", "iam:ListPolicyTags"]
        Resource = ["arn:aws:iam::${local.account_id}:policy/uptime-${env}-workload-boundary"]
      },
    ]
  }

  write_statements = {
    for env in local.environments : env => [
      {
        Sid      = "StateWrite"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["arn:aws:s3:::${local.state_bucket}/platform/${env}/terraform.tfstate"]
      },
      {
        Sid      = "ManageTables"
        Effect   = "Allow"
        Action   = ["dynamodb:CreateTable", "dynamodb:DeleteTable", "dynamodb:UpdateTable", "dynamodb:UpdateTimeToLive", "dynamodb:UpdateContinuousBackups", "dynamodb:TagResource", "dynamodb:UntagResource"]
        Resource = ["arn:aws:dynamodb:*:${local.account_id}:table/uptime-${env}-*"]
      },
      {
        Sid      = "ManageFunctions"
        Effect   = "Allow"
        Action   = ["lambda:CreateFunction", "lambda:DeleteFunction", "lambda:UpdateFunctionCode", "lambda:UpdateFunctionConfiguration", "lambda:TagResource", "lambda:UntagResource"]
        Resource = ["arn:aws:lambda:*:${local.account_id}:function:uptime-${env}-*"]
      },
      {
        Sid      = "ManageSchedules"
        Effect   = "Allow"
        Action   = ["scheduler:CreateSchedule", "scheduler:UpdateSchedule", "scheduler:DeleteSchedule", "scheduler:TagResource", "scheduler:UntagResource"]
        Resource = ["arn:aws:scheduler:*:${local.account_id}:schedule/default/uptime-${env}-*"]
      },
      {
        Sid      = "ManageLogGroups"
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:DeleteLogGroup", "logs:PutRetentionPolicy", "logs:DeleteRetentionPolicy", "logs:TagResource", "logs:UntagResource", "logs:TagLogGroup", "logs:UntagLogGroup"]
        Resource = ["arn:aws:logs:*:${local.account_id}:log-group:/aws/lambda/uptime-${env}-*"]
      },
      {
        Sid      = "ManageTopics"
        Effect   = "Allow"
        Action   = ["sns:CreateTopic", "sns:DeleteTopic", "sns:SetTopicAttributes", "sns:Subscribe", "sns:Unsubscribe", "sns:SetSubscriptionAttributes", "sns:TagResource", "sns:UntagResource"]
        Resource = ["arn:aws:sns:*:${local.account_id}:uptime-${env}-*"]
      },
      {
        Sid      = "ManageStatusBucket"
        Effect   = "Allow"
        Action   = ["s3:CreateBucket", "s3:DeleteBucket", "s3:PutBucketPolicy", "s3:DeleteBucketPolicy", "s3:PutBucketPublicAccessBlock", "s3:PutBucketOwnershipControls", "s3:PutEncryptionConfiguration", "s3:PutBucketTagging"]
        Resource = ["arn:aws:s3:::uptime-${env}-status-*"]
      },
      {
        Sid      = "ManageStatusObjects"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:DeleteObject", "s3:DeleteObjectVersion", "s3:PutObjectTagging"]
        Resource = ["arn:aws:s3:::uptime-${env}-status-*/*"]
      },
      {
        Sid      = "ManageCloudFront"
        Effect   = "Allow"
        Action   = ["cloudfront:CreateDistribution", "cloudfront:UpdateDistribution", "cloudfront:DeleteDistribution", "cloudfront:TagResource", "cloudfront:UntagResource", "cloudfront:CreateOriginAccessControl", "cloudfront:UpdateOriginAccessControl", "cloudfront:DeleteOriginAccessControl"]
        Resource = ["*"]
      },
      {
        Sid      = "ManageBudgets"
        Effect   = "Allow"
        Action   = ["budgets:ModifyBudget", "budgets:TagResource", "budgets:UntagResource"]
        Resource = ["arn:aws:budgets::${local.account_id}:budget/uptime-${env}-*"]
      },
      {
        Sid      = "CreateRolesOnlyWithBoundary"
        Effect   = "Allow"
        Action   = ["iam:CreateRole", "iam:PutRolePolicy", "iam:PutRolePermissionsBoundary"]
        Resource = ["arn:aws:iam::${local.account_id}:role/uptime-${env}-*"]
        Condition = {
          StringEquals = {
            "iam:PermissionsBoundary" = "arn:aws:iam::${local.account_id}:policy/uptime-${env}-workload-boundary"
          }
        }
      },
      {
        Sid      = "ManageWorkloadRoles"
        Effect   = "Allow"
        Action   = ["iam:DeleteRole", "iam:DeleteRolePolicy", "iam:TagRole", "iam:UntagRole", "iam:UpdateRole", "iam:UpdateAssumeRolePolicy", "iam:ListInstanceProfilesForRole"]
        Resource = ["arn:aws:iam::${local.account_id}:role/uptime-${env}-*"]
      },
      {
        Sid      = "PassRolesOnlyToWorkloadServices"
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = ["arn:aws:iam::${local.account_id}:role/uptime-${env}-*"]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = ["lambda.amazonaws.com", "scheduler.amazonaws.com"]
          }
        }
      },
      {
        Sid      = "DenyBoundaryRemoval"
        Effect   = "Deny"
        Action   = ["iam:DeleteRolePermissionsBoundary"]
        Resource = ["*"]
      },
      {
        Sid      = "DenyBoundaryChanges"
        Effect   = "Deny"
        Action   = ["iam:CreatePolicy", "iam:CreatePolicyVersion", "iam:DeletePolicy", "iam:DeletePolicyVersion", "iam:SetDefaultPolicyVersion"]
        Resource = ["arn:aws:iam::${local.account_id}:policy/uptime-${env}-workload-boundary"]
      },
    ]
  }
}