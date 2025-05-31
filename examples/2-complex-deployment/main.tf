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
