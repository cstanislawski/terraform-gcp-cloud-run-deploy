# terraform-gcp-cloud-run-deploy

A Terraform module to deploy a Cloud Run Service using a Kubernetes-like syntax.

This module provides a Kubernetes-like interface for deploying Cloud Run services, making it easier for teams familiar with Kubernetes to adopt Cloud Run.

## Features

- **Kubernetes-like syntax** - Use familiar `metadata`, `spec`, and `template` structures
- **Manifest file support** - Load configuration from YAML files
- **Parameter overrides** - Direct module parameters override manifest values
- **Multiple containers** - Support for sidecar containers (similar to Kubernetes pods)
- **Volume management** - Support for secrets, Cloud SQL instances, and empty directories
- **Health checks** - Startup and liveness probes with HTTP, TCP, and gRPC support
- **Resource management** - CPU and memory limits with Cloud Run-specific optimizations
- **Environment variables** - Support for both static values and secret references
- **Traffic management** - Blue-green and canary deployments
- **Auto-scaling** - Configure min/max instances (equivalent to replicas)

## Usage

### Using Manifest Files (Recommended)

Create a `deployment.yaml` file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app
  location: us-central1
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

Then use it in Terraform:

```hcl
module "hello_app" {
  source = "github.com/cstanislawski/terraform-gcp-cloud-run-deploy"

  manifest_path = "./deployment.yaml"
}
```

### Using Manifest Files with Overrides

```hcl
module "hello_app_staging" {
  source = "github.com/cstanislawski/terraform-gcp-cloud-run-deploy"

  manifest_path = "./deployment.yaml"

  # Override for staging environment
  metadata = {
    name     = "hello-app-staging"
    location = "us-west1"
  }

  template = {
    spec = {
      containers = [
        {
          name = "hello-app"
          env = [
            {
              name  = "ENV"
              value = "staging"
            }
          ]
        }
      ]
    }
  }
}
```

### Direct Configuration (No Manifest)

```hcl
module "hello_app" {
  source = "github.com/cstanislawski/terraform-gcp-cloud-run-deploy"

  # Kubernetes-like metadata
  metadata = {
    name     = "hello-app"
    location = "us-central1"
    project  = "my-gcp-project"
  }

  # Kubernetes-like spec (replicas equivalent)
  spec = {
    replicas = 2
  }

  # Kubernetes-like template
  template = {
    metadata = {
      labels = {
        app = "hello-app"
      }
    }
    spec = {
      containers = [
        {
          name  = "hello-app"
          image = "gcr.io/google-samples/hello-app:2.0"

          ports = [
            {
              containerPort = 8080
            }
          ]

          resources = {
            limits = {
              cpu    = "1000m"
              memory = "512Mi"
            }
          }
        }
      ]
    }
  }
}
```

## Kubernetes to Cloud Run Mapping

| Kubernetes Concept | Cloud Run Equivalent | This Module |
|-------------------|---------------------|-------------|
| `metadata.name` | Service name | `metadata.name` |
| `metadata.namespace` | Project/Location | `metadata.project`/`metadata.location` |
| `metadata.labels` | Template labels | `template.metadata.labels` |
| `spec.replicas` | Min/Max instances | `spec.replicas` |
| `spec.template.spec.containers` | Containers | `template.spec.containers` |
| `spec.template.spec.volumes` | Volumes | `template.spec.volumes` |
| `containers[].image` | Container image | `containers[].image` |
| `containers[].ports` | Container ports | `containers[].ports` |
| `containers[].env` | Environment variables | `containers[].env` |
| `containers[].volumeMounts` | Volume mounts | `containers[].volumeMounts` |
| `containers[].resources` | Resource limits | `containers[].resources` |
| `containers[].livenessProbe` | Liveness probe | `containers[].livenessProbe` |
| `containers[].startupProbe` | Startup probe | `containers[].startupProbe` |
| `containers[].readinessProbe` | Readiness probe | `containers[].readinessProbe` |
| `spec.serviceAccountName` | Service account | `template.spec.serviceAccountName` |
| `spec.nodeSelector` | Node selector | `template.spec.nodeSelector` |

## Variables

### Optional Variables

- `manifest_path` - Path to a Kubernetes-like YAML manifest file
- `metadata` - Service metadata including name, location, and project
- `template` - Template specification including containers
- `spec` - Scaling configuration (defaults to 1 replica)
- `traffic` - Traffic allocation (defaults to 100% latest)
- `ingress` - Ingress configuration (defaults to all traffic)
- `binaryAuthorization` - Binary authorization settings

**Note**: When using `manifest_path`, direct module parameters will override manifest values.

## Outputs

- `service_name` - The name of the Cloud Run service
- `service_uri` - The URL of the Cloud Run service
- `service_id` - The unique identifier of the service
- `location` - The deployment location
- `project` - The deployment project
- `latest_ready_revision` - The latest ready revision
- `latest_created_revision` - The latest created revision
- `traffic` - Current traffic allocation
- `conditions` - Service conditions
- `observed_generation` - Observed generation
- `terminal_condition` - Terminal condition

## Examples

See the `examples/` directory for complete working examples:

- [`examples/1-simple-deployment/`](./examples/1-simple-deployment/) - Basic single-container deployment using manifest
- [`examples/2-complex-deployment/`](./examples/2-complex-deployment/) - Multi-container deployment with manifest and overrides

## Requirements

- Terraform >= 1.3
- Google Cloud Provider >= 4.84.0
- Appropriate GCP permissions for Cloud Run

## License

Apache 2.0 - see [LICENSE](./LICENSE) file for details.
