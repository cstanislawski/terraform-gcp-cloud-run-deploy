# Complex Cloud Run Deployment Example

This example demonstrates advanced Cloud Run features using a Kubernetes manifest file with parameter overrides.

## Files

- `deployment.yaml` - Kubernetes-like manifest file with complex configuration
- `main.tf` - Terraform configuration that loads the manifest and overrides for staging

## Features Demonstrated

- Multiple containers
- Volume mounts and secrets
- Environment variables from secrets
- Health checks (startup and liveness probes)
- Resource limits and optimization
- Service accounts
- Parameter overrides for environment-specific deployments

## Key Features

- Manifest-based - Complex configuration defined in familiar Kubernetes YAML
- Parameter overrides - Terraform parameters override manifest values
- Environment flexibility - Same manifest, different environments via overrides
- Partial overrides - Only override what you need to change

## Override Behavior

- Direct parameters take precedence over manifest values
- Labels are merged (Terraform labels added to manifest labels)
- Arrays are replaced (not merged) when overridden
- Missing parameters fall back to manifest values

## Usage

1. Update `deployment.yaml`:
   - Change `metadata.project` to your GCP project ID
   - Update service account, secrets, and other resources
   - Modify container images and configurations

2. Customize overrides in `main.tf`:
   - Change environment-specific values
   - Override locations, names, or other settings
   - Add environment-specific environment variables

3. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

Before running this example, ensure you have:

1. A GCP project with Cloud Run API enabled
2. A service account: `my-service-account@my-gcp-project.iam.gserviceaccount.com`
3. Secrets created in Secret Manager:
   - `app-config` - Application configuration
   - `db-credentials` - Database credentials

## Outputs

After deployment, you'll receive:

- Service URL for accessing the application
- Service name and revision information
- Traffic allocation details
