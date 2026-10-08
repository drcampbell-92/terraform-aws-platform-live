output "status_page_url" {
  description = "Public address of the dev status page"
  value       = module.status_page.url
}

output "checker_function_name" {
  description = "Name of the checker function, for manual test runs"
  value       = module.monitor.function_name
}

output "alert_topic_arn" {
  description = "ARN of the alerts topic"
  value       = module.alerts.topic_arn
}