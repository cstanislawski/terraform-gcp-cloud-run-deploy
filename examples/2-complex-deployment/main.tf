# Create secrets for testing
resource "google_secret_manager_secret" "app_config" {
  secret_id = "app-config"
  project   = "test-432108"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "app_config_version" {
  secret = google_secret_manager_secret.app_config.id
  secret_data = jsonencode({
    database_url = "postgresql://localhost:5432/myapp"
    api_key      = "test-api-key-12345"
    environment  = "staging"
  })
}

resource "google_secret_manager_secret" "db_credentials" {
  secret_id = "db-credentials"
  project   = "test-432108"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_credentials_version" {
  secret      = google_secret_manager_secret.db_credentials.id
  secret_data = "super-secret-db-password-staging"
}

# Complex example: Load from deployment.yaml and override for staging
module "complex_app_deployment" {
  source = "../../" # while actually using the module, you'd use 'source = "github.com/cstanislawski/terraform-gcp-cloud-run-deploy"'

  manifest_path = "./deployment.yaml"

  deletion_protection = false

  # Override for staging environment
  metadata = {
    name     = "complex-app-staging"
    location = "us-west1"
    # project inherited from manifest
  }

  # Override environment variable
  template = {
    spec = {
      containers = [
        {
          name = "complex-app"
          env = [
            {
              name  = "ENV"
              value = "staging" # Override from production to staging
            }
          ]
        }
      ]
    }
  }

  # Ensure secrets are created first
  depends_on = [
    google_secret_manager_secret_version.app_config_version,
    google_secret_manager_secret_version.db_credentials_version
  ]
}

output "service_uri" {
  description = "The URL of the deployed Cloud Run service"
  value       = module.complex_app_deployment.service_uri
}

output "service_name" {
  description = "The name of the deployed Cloud Run service"
  value       = module.complex_app_deployment.service_name
}

output "latest_revision" {
  description = "The latest ready revision"
  value       = module.complex_app_deployment.latest_ready_revision
}
