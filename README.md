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

## Examples

See the `examples/` directory for complete working examples:

- [`examples/1-simple-deployment/`](./examples/1-simple-deployment/) - Basic single-container deployment using manifest
- [`examples/2-complex-deployment/`](./examples/2-complex-deployment/) - Multi-container deployment with manifest and overrides

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.84.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.84.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_v2_service.cloudrun_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_binaryAuthorization"></a> [binaryAuthorization](#input\_binaryAuthorization) | Binary authorization configuration for the Cloud Run service | <pre>object({<br/>    useDefault              = optional(bool, false)<br/>    breakglassJustification = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_client"></a> [client](#input\_client) | Arbitrary identifier for the API client | `string` | `null` | no |
| <a name="input_client_version"></a> [client\_version](#input\_client\_version) | Arbitrary version identifier for the API client | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether Terraform will be prevented from destroying the service. Defaults to true. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | User-provided description of the Cloud Run service | `string` | `null` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Ingress configuration for the Cloud Run service | `string` | `null` | no |
| <a name="input_invoker_iam_disabled"></a> [invoker\_iam\_disabled](#input\_invoker\_iam\_disabled) | Whether to disable IAM for the invoker. Defaults to false. | `bool` | `false` | no |
| <a name="input_launch_stage"></a> [launch\_stage](#input\_launch\_stage) | The launch stage as defined by Google Cloud Platform Launch Stages | `string` | `null` | no |
| <a name="input_manifest_path"></a> [manifest\_path](#input\_manifest\_path) | Path to a Kubernetes-like YAML manifest file. Direct module parameters will override manifest values. | `string` | `null` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | Metadata for the Cloud Run service (similar to Kubernetes metadata) | <pre>object({<br/>    name     = string<br/>    location = string<br/>    project  = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_spec"></a> [spec](#input\_spec) | Specification for the Cloud Run service (similar to Kubernetes spec) | <pre>object({<br/>    replicas = optional(number, 1)<br/>  })</pre> | `null` | no |
| <a name="input_template"></a> [template](#input\_template) | Template specification for the Cloud Run service (similar to Kubernetes template) | <pre>object({<br/>    metadata = optional(object({<br/>      labels = optional(map(string), {})<br/>    }), {})<br/>    spec = object({<br/>      serviceAccountName   = optional(string)<br/>      executionEnvironment = optional(string, "EXECUTION_ENVIRONMENT_GEN2")<br/><br/>      vpcAccess = optional(object({<br/>        connector = optional(string)<br/>        egress    = optional(string, "PRIVATE_RANGES_ONLY")<br/>      }))<br/><br/>      nodeSelector = optional(object({<br/>        accelerator = optional(string)<br/>      }))<br/><br/>      volumes = optional(list(object({<br/>        name = string<br/>        secret = optional(object({<br/>          secretName  = string<br/>          defaultMode = optional(number, 0644)<br/>          items = optional(list(object({<br/>            version = string<br/>            path    = string<br/>            mode    = optional(number, 0644)<br/>          })))<br/>        }))<br/>        cloudSqlInstance = optional(object({<br/>          instances = list(string)<br/>        }))<br/>        emptyDir = optional(object({<br/>          medium    = optional(string, "MEMORY")<br/>          sizeLimit = optional(string)<br/>        }))<br/>      })), [])<br/><br/>      containers = list(object({<br/>        name       = string<br/>        image      = optional(string)<br/>        command    = optional(list(string))<br/>        args       = optional(list(string))<br/>        workingDir = optional(string)<br/><br/>        env = optional(list(object({<br/>          name  = string<br/>          value = optional(string)<br/>          valueFrom = optional(object({<br/>            secretKeyRef = optional(object({<br/>              name = string<br/>              key  = string<br/>            }))<br/>          }))<br/>        })), [])<br/><br/>        resources = optional(object({<br/>          limits = object({<br/>            cpu    = string<br/>            memory = string<br/>          })<br/>          cpuIdle         = optional(bool, true)<br/>          startupCpuBoost = optional(bool, false)<br/>        }))<br/><br/>        ports = optional(list(object({<br/>          name          = optional(string)<br/>          containerPort = number<br/>        })), [])<br/><br/>        volumeMounts = optional(list(object({<br/>          name      = string<br/>          mountPath = string<br/>        })), [])<br/><br/>        startupProbe = optional(object({<br/>          initialDelaySeconds = optional(number, 0)<br/>          timeoutSeconds      = optional(number, 1)<br/>          periodSeconds       = optional(number, 10)<br/>          failureThreshold    = optional(number, 3)<br/><br/>          httpGet = optional(object({<br/>            path = optional(string, "/")<br/>            port = optional(number, 8080)<br/>            httpHeaders = optional(list(object({<br/>              name  = string<br/>              value = string<br/>            })))<br/>          }))<br/><br/>          tcpSocket = optional(object({<br/>            port = number<br/>          }))<br/><br/>          grpc = optional(object({<br/>            port    = optional(number, 8080)<br/>            service = optional(string)<br/>          }))<br/>        }))<br/><br/>        livenessProbe = optional(object({<br/>          initialDelaySeconds = optional(number, 0)<br/>          timeoutSeconds      = optional(number, 1)<br/>          periodSeconds       = optional(number, 10)<br/>          failureThreshold    = optional(number, 3)<br/><br/>          httpGet = optional(object({<br/>            path = optional(string, "/")<br/>            port = optional(number, 8080)<br/>            httpHeaders = optional(list(object({<br/>              name  = string<br/>              value = string<br/>            })))<br/>          }))<br/><br/>          tcpSocket = optional(object({<br/>            port = number<br/>          }))<br/><br/>          grpc = optional(object({<br/>            port    = optional(number, 8080)<br/>            service = optional(string)<br/>          }))<br/>        }))<br/><br/>        readinessProbe = optional(object({<br/>          initialDelaySeconds = optional(number, 0)<br/>          timeoutSeconds      = optional(number, 1)<br/>          periodSeconds       = optional(number, 10)<br/>          failureThreshold    = optional(number, 3)<br/><br/>          httpGet = optional(object({<br/>            path = optional(string, "/")<br/>            port = optional(number, 8080)<br/>            httpHeaders = optional(list(object({<br/>              name  = string<br/>              value = string<br/>            })))<br/>          }))<br/><br/>          tcpSocket = optional(object({<br/>            port = number<br/>          }))<br/><br/>          grpc = optional(object({<br/>            port    = optional(number, 8080)<br/>            service = optional(string)<br/>          }))<br/>        }))<br/>      }))<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_traffic"></a> [traffic](#input\_traffic) | Traffic allocation for the Cloud Run service | <pre>list(object({<br/>    type     = optional(string, "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST")<br/>    revision = optional(string)<br/>    percent  = optional(number, 100)<br/>    tag      = optional(string)<br/>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_conditions"></a> [conditions](#output\_conditions) | The conditions of the Cloud Run service |
| <a name="output_latest_created_revision"></a> [latest\_created\_revision](#output\_latest\_created\_revision) | The latest created revision of the Cloud Run service |
| <a name="output_latest_ready_revision"></a> [latest\_ready\_revision](#output\_latest\_ready\_revision) | The latest ready revision of the Cloud Run service |
| <a name="output_location"></a> [location](#output\_location) | The location where the Cloud Run service is deployed |
| <a name="output_observed_generation"></a> [observed\_generation](#output\_observed\_generation) | The observed generation of the Cloud Run service |
| <a name="output_project"></a> [project](#output\_project) | The project where the Cloud Run service is deployed |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | The unique identifier of the Cloud Run service |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | The name of the Cloud Run service |
| <a name="output_service_uri"></a> [service\_uri](#output\_service\_uri) | The URL of the Cloud Run service |
| <a name="output_terminal_condition"></a> [terminal\_condition](#output\_terminal\_condition) | The terminal condition of the Cloud Run service |
| <a name="output_traffic"></a> [traffic](#output\_traffic) | The traffic allocation for the Cloud Run service |
<!-- END_TF_DOCS -->

## License

Apache 2.0 - see [LICENSE](./LICENSE) file for details.
