output "service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_v2_service.cloudrun_service.name
}

output "service_uri" {
  description = "The URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.cloudrun_service.uri
}

output "service_id" {
  description = "The unique identifier of the Cloud Run service"
  value       = google_cloud_run_v2_service.cloudrun_service.id
}

output "location" {
  description = "The location where the Cloud Run service is deployed"
  value       = google_cloud_run_v2_service.cloudrun_service.location
}

output "project" {
  description = "The project where the Cloud Run service is deployed"
  value       = google_cloud_run_v2_service.cloudrun_service.project
}

output "latest_ready_revision" {
  description = "The latest ready revision of the Cloud Run service"
  value       = google_cloud_run_v2_service.cloudrun_service.latest_ready_revision
}

output "latest_created_revision" {
  description = "The latest created revision of the Cloud Run service"
  value       = google_cloud_run_v2_service.cloudrun_service.latest_created_revision
}

output "traffic" {
  description = "The traffic allocation for the Cloud Run service"
  value       = google_cloud_run_v2_service.cloudrun_service.traffic
}

output "conditions" {
  description = "The conditions of the Cloud Run service"
  value       = google_cloud_run_v2_service.cloudrun_service.conditions
}

output "observed_generation" {
  description = "The observed generation of the Cloud Run service"
  value       = google_cloud_run_v2_service.cloudrun_service.observed_generation
}

output "terminal_condition" {
  description = "The terminal condition of the Cloud Run service"
  value       = google_cloud_run_v2_service.cloudrun_service.terminal_condition
}
