# Manifest file support (optional)
variable "manifest_path" {
  type        = string
  description = "Path to a Kubernetes-like YAML manifest file. Direct module parameters will override manifest values."
  default     = null
}

# Kubernetes-like metadata structure
variable "metadata" {
  type = object({
    name     = string
    location = string
    project  = optional(string)
  })
  description = "Metadata for the Cloud Run service (similar to Kubernetes metadata)"
  default     = null
}

# Kubernetes-like spec structure
variable "spec" {
  type = object({
    replicas = optional(number, 1)
  })
  description = "Specification for the Cloud Run service (similar to Kubernetes spec)"
  default     = null
}

# Kubernetes-like template structure
variable "template" {
  type = object({
    metadata = optional(object({
      labels = optional(map(string), {})
    }), {})
    spec = object({
      serviceAccountName   = optional(string)
      executionEnvironment = optional(string, "EXECUTION_ENVIRONMENT_GEN2")

      vpcAccess = optional(object({
        connector = optional(string)
        egress    = optional(string, "PRIVATE_RANGES_ONLY")
      }))

      nodeSelector = optional(object({
        accelerator = optional(string)
      }))

      volumes = optional(list(object({
        name = string
        secret = optional(object({
          secretName  = string
          defaultMode = optional(number, 0644)
          items = optional(list(object({
            version = string
            path    = string
            mode    = optional(number, 0644)
          })))
        }))
        cloudSqlInstance = optional(object({
          instances = list(string)
        }))
        emptyDir = optional(object({
          medium    = optional(string, "MEMORY")
          sizeLimit = optional(string)
        }))
      })), [])

      containers = list(object({
        name       = string
        image      = optional(string)
        command    = optional(list(string))
        args       = optional(list(string))
        workingDir = optional(string)

        env = optional(list(object({
          name  = string
          value = optional(string)
          valueFrom = optional(object({
            secretKeyRef = optional(object({
              name = string
              key  = string
            }))
          }))
        })), [])

        resources = optional(object({
          limits = object({
            cpu    = string
            memory = string
          })
          cpuIdle         = optional(bool, true)
          startupCpuBoost = optional(bool, false)
        }))

        ports = optional(list(object({
          name          = optional(string)
          containerPort = number
        })), [])

        volumeMounts = optional(list(object({
          name      = string
          mountPath = string
        })), [])

        startupProbe = optional(object({
          initialDelaySeconds = optional(number, 0)
          timeoutSeconds      = optional(number, 1)
          periodSeconds       = optional(number, 10)
          failureThreshold    = optional(number, 3)

          httpGet = optional(object({
            path = optional(string, "/")
            port = optional(number, 8080)
            httpHeaders = optional(list(object({
              name  = string
              value = string
            })))
          }))

          tcpSocket = optional(object({
            port = number
          }))

          grpc = optional(object({
            port    = optional(number, 8080)
            service = optional(string)
          }))
        }))

        livenessProbe = optional(object({
          initialDelaySeconds = optional(number, 0)
          timeoutSeconds      = optional(number, 1)
          periodSeconds       = optional(number, 10)
          failureThreshold    = optional(number, 3)

          httpGet = optional(object({
            path = optional(string, "/")
            port = optional(number, 8080)
            httpHeaders = optional(list(object({
              name  = string
              value = string
            })))
          }))

          tcpSocket = optional(object({
            port = number
          }))

          grpc = optional(object({
            port    = optional(number, 8080)
            service = optional(string)
          }))
        }))

        readinessProbe = optional(object({
          initialDelaySeconds = optional(number, 0)
          timeoutSeconds      = optional(number, 1)
          periodSeconds       = optional(number, 10)
          failureThreshold    = optional(number, 3)

          httpGet = optional(object({
            path = optional(string, "/")
            port = optional(number, 8080)
            httpHeaders = optional(list(object({
              name  = string
              value = string
            })))
          }))

          tcpSocket = optional(object({
            port = number
          }))

          grpc = optional(object({
            port    = optional(number, 8080)
            service = optional(string)
          }))
        }))
      }))
    })
  })
  description = "Template specification for the Cloud Run service (similar to Kubernetes template)"
  default     = null
}

# Traffic configuration
variable "traffic" {
  type = list(object({
    type     = optional(string, "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST")
    revision = optional(string)
    percent  = optional(number, 100)
    tag      = optional(string)
  }))
  description = "Traffic allocation for the Cloud Run service"
  default     = null
}

# Ingress configuration
variable "ingress" {
  type        = string
  description = "Ingress configuration for the Cloud Run service"
  default     = null
  validation {
    condition = var.ingress == null ? true : contains([
      "INGRESS_TRAFFIC_ALL",
      "INGRESS_TRAFFIC_INTERNAL_ONLY",
      "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
    ], var.ingress)
    error_message = "Ingress must be one of: INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER."
  }
}

# Binary authorization
variable "binaryAuthorization" {
  type = object({
    useDefault              = optional(bool, false)
    breakglassJustification = optional(string)
  })
  description = "Binary authorization configuration for the Cloud Run service"
  default     = null
}

variable "deletion_protection" {
  type        = bool
  description = "Whether Terraform will be prevented from destroying the service. Defaults to true."
  default     = true
}

variable "description" {
  type        = string
  description = "User-provided description of the Cloud Run service"
  default     = null
}

variable "client" {
  type        = string
  description = "Arbitrary identifier for the API client"
  default     = null
}

variable "client_version" {
  type        = string
  description = "Arbitrary version identifier for the API client"
  default     = null
}

variable "launch_stage" {
  type        = string
  description = "The launch stage as defined by Google Cloud Platform Launch Stages"
  default     = null
  validation {
    condition = var.launch_stage == null ? true : contains([
      "UNIMPLEMENTED",
      "PRELAUNCH",
      "EARLY_ACCESS",
      "ALPHA",
      "BETA",
      "GA",
      "DEPRECATED"
    ], var.launch_stage)
    error_message = "Launch stage must be one of: UNIMPLEMENTED, PRELAUNCH, EARLY_ACCESS, ALPHA, BETA, GA, DEPRECATED."
  }
}
