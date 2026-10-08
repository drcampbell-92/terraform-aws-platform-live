variable "alert_emails" {
  type        = list(string)
  description = "Addresses that receive uptime failure alerts"
}

variable "budget_alert_emails" {
  type        = list(string)
  description = "Addresses that receive budget alerts"
}