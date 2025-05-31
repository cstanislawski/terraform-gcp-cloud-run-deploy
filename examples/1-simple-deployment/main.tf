# Simple example: Load everything from deployment.yaml
module "hello_app_deployment" {
  source = "../../" # while actually using the module, you'd use 'source = "github.com/cstanislawski/terraform-gcp-cloud-run-deploy"'

  manifest_path = "./deployment.yaml"
}

output "service_uri" {
  description = "The URL of the deployed Cloud Run service"
  value       = module.hello_app_deployment.service_uri
}
