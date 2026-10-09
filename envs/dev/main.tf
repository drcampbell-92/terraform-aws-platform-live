locals {
  name_prefix    = "uptime-dev"
  module_source  = "git::https://github.com/drcampbell-92/terraform-aws-platform-modules.git//modules"
  module_version = "v1.0.1"

  targets = {
    vpc-ec2-project      = "https://github.com/drcampbell-92/terraform-aws-vpc-ec2"
    remote-state-project = "https://github.com/drcampbell-92/terraform-aws-remote-state-modules"
    serverless-project   = "https://github.com/drcampbell-92/terraform-aws-serverless-api"
  }
}

module "guardrails" {
  source = "git::https://github.com/drcampbell-92/terraform-aws-platform-modules.git//modules/guardrails?ref=v1.0.1"

  name_prefix         = local.name_prefix
  environment         = "dev"
  monthly_budget_usd  = 5
  budget_alert_emails = var.budget_alert_emails
}

module "alerts" {
  source = "git::https://github.com/drcampbell-92/terraform-aws-platform-modules.git//modules/alerts?ref=v1.0.1"

  name_prefix            = local.name_prefix
  allowed_publisher_arns = [module.monitor.role_arn]
  email_addresses        = var.alert_emails
}

module "status_page" {
  source = "git::https://github.com/drcampbell-92/terraform-aws-platform-modules.git//modules/status-page?ref=v1.0.1"

  name_prefix   = local.name_prefix
  page_title    = "Uptime dev status"
  force_destroy = true
}

module "monitor" {
  source = "git::https://github.com/drcampbell-92/terraform-aws-platform-modules.git//modules/monitor?ref=v1.0.1"

  name_prefix              = local.name_prefix
  targets                  = local.targets
  alert_topic_arn          = module.alerts.topic_arn
  status_bucket_name       = module.status_page.bucket_name
  permissions_boundary_arn = module.guardrails.permissions_boundary_arn
}