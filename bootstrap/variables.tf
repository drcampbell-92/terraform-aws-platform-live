variable "github_repo" {
  type        = string
  description = "GitHub repository, as owner/name, allowed to assume the pipeline roles"
  default     = "drcampbell-92/terraform-aws-platform-live"
}