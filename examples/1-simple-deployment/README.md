# Simple Cloud Run Deployment Example

This example demonstrates how to deploy a simple single-container Cloud Run service using a Kubernetes manifest file.

## Files

- `deployment.yaml` - Kubernetes-like manifest file
- `main.tf` - Terraform configuration that loads the manifest

## Kubernetes Deployment (deployment.yaml)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app
  location: europe-west4
  project: my-gcp-project
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: hello-app
    spec:
      containers:
      - name: hello-app
        image: gcr.io/google-samples/hello-app:2.0
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: 1000m
            memory: 512Mi
```

## Terraform Module (main.tf)

```hcl
# Simple example: Load everything from deployment.yaml
module "hello_app_deployment" {
  source = "../../"

  manifest_path = "./deployment.yaml"
}

output "service_uri" {
  description = "The URL of the deployed Cloud Run service"
  value       = module.hello_app_deployment.service_uri
}
```

## Key Features

1. **Manifest-based**: Configuration is defined in a familiar Kubernetes YAML format
2. **Simple**: Just point to the manifest file - no complex Terraform configuration
3. **Familiar**: Uses the same structure as Kubernetes Deployments
4. **GCP Extensions**: Adds `location` and `project` to metadata for Cloud Run

## Usage

1. Update `deployment.yaml`:
   - Change `metadata.project` to your GCP project ID
   - Change `metadata.location` to your preferred region
   - Modify other settings as needed

2. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

After deployment, you'll get the service URL that you can use to access your application.
