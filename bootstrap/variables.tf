variable "github_owner" {
  type        = string
  description = "GitHub account that owns the live repository"
  default     = "drcampbell-92"
}

variable "github_owner_id" {
  type        = string
  description = "Numeric ID of the GitHub account, as it appears in OIDC sub claims"
  default     = "331302034"
}

variable "github_repo" {
  type        = string
  description = "Name of the live repository"
  default     = "terraform-aws-platform-live"
}

variable "github_repo_id" {
  type        = string
  description = "Numeric ID of the live repository, as it appears in OIDC sub claims"
  default     = "1406272903"
}