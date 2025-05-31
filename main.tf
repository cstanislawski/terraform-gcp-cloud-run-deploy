resource "google_cloud_run_v2_service" "cloudrun_service" {
  name     = local.final_metadata.name
  location = local.final_metadata.location
  project  = local.final_metadata.project

  # Additional service parameters
  deletion_protection = var.deletion_protection
  description         = var.description
  client              = var.client
  client_version      = var.client_version
  launch_stage        = var.launch_stage

  template {
    labels = local.final_template.metadata.labels
    annotations = local.final_template.metadata.annotations

    scaling {
      min_instance_count = local.merged_spec.replicas
      max_instance_count = local.merged_spec.replicas
    }

    service_account = local.final_template.spec.serviceAccountName

    execution_environment = local.final_template.spec.executionEnvironment

    dynamic "vpc_access" {
      for_each = local.final_template.spec.vpcAccess != null ? [local.final_template.spec.vpcAccess] : []
      content {
        connector = vpc_access.value.connector
        egress    = vpc_access.value.egress
      }
    }

    dynamic "node_selector" {
      for_each = local.final_template.spec.nodeSelector != null ? [local.final_template.spec.nodeSelector] : []
      content {
        accelerator = node_selector.value.accelerator
      }
    }

    dynamic "volumes" {
      for_each = local.final_template.spec.volumes
      content {
        name = volumes.value.name

        dynamic "secret" {
          for_each = volumes.value.secret != null ? [volumes.value.secret] : []
          content {
            secret       = secret.value.secretName
            default_mode = secret.value.defaultMode
            dynamic "items" {
              for_each = secret.value.items != null ? secret.value.items : []
              content {
                version = items.value.version
                path    = items.value.path
                mode    = items.value.mode
              }
            }
          }
        }

        dynamic "cloud_sql_instance" {
          for_each = volumes.value.cloudSqlInstance != null ? [volumes.value.cloudSqlInstance] : []
          content {
            instances = cloud_sql_instance.value.instances
          }
        }

        dynamic "empty_dir" {
          for_each = volumes.value.emptyDir != null ? [volumes.value.emptyDir] : []
          content {
            medium     = empty_dir.value.medium
            size_limit = empty_dir.value.sizeLimit
          }
        }
      }
    }

    # Containers (similar to containers in K8s)
    dynamic "containers" {
      for_each = local.final_template.spec.containers
      content {
        name  = containers.value.name
        image = containers.value.image

        # Command and args (similar to command and args in K8s)
        command = containers.value.command
        args    = containers.value.args

        # Working directory
        working_dir = containers.value.workingDir

        # Environment variables (similar to env in K8s)
        dynamic "env" {
          for_each = containers.value.env != null ? containers.value.env : []
          content {
            name  = env.value.name
            value = env.value.value

            dynamic "value_source" {
              for_each = env.value.valueFrom != null ? [env.value.valueFrom] : []
              content {
                dynamic "secret_key_ref" {
                  for_each = value_source.value.secretKeyRef != null ? [value_source.value.secretKeyRef] : []
                  content {
                    secret  = secret_key_ref.value.name
                    version = secret_key_ref.value.key
                  }
                }
              }
            }
          }
        }

        # Resources (similar to resources in K8s)
        resources {
          limits = {
            cpu    = containers.value.resources.limits.cpu
            memory = containers.value.resources.limits.memory
          }
          cpu_idle          = containers.value.resources.cpuIdle
          startup_cpu_boost = containers.value.resources.startupCpuBoost
        }

        # Ports (similar to ports in K8s)
        dynamic "ports" {
          for_each = containers.value.ports != null ? containers.value.ports : []
          content {
            name           = ports.value.name
            container_port = ports.value.containerPort
          }
        }

        # Volume mounts (similar to volumeMounts in K8s)
        dynamic "volume_mounts" {
          for_each = containers.value.volumeMounts != null ? containers.value.volumeMounts : []
          content {
            name       = volume_mounts.value.name
            mount_path = volume_mounts.value.mountPath
          }
        }

        # Startup probe (similar to startupProbe in K8s)
        dynamic "startup_probe" {
          for_each = containers.value.startupProbe != null ? [containers.value.startupProbe] : []
          content {
            initial_delay_seconds = startup_probe.value.initialDelaySeconds
            timeout_seconds       = startup_probe.value.timeoutSeconds
            period_seconds        = startup_probe.value.periodSeconds
            failure_threshold     = startup_probe.value.failureThreshold

            dynamic "http_get" {
              for_each = startup_probe.value.httpGet != null ? [startup_probe.value.httpGet] : []
              content {
                path = http_get.value.path
                port = http_get.value.port
                dynamic "http_headers" {
                  for_each = http_get.value.httpHeaders != null ? http_get.value.httpHeaders : []
                  content {
                    name  = http_headers.value.name
                    value = http_headers.value.value
                  }
                }
              }
            }

            dynamic "tcp_socket" {
              for_each = startup_probe.value.tcpSocket != null ? [startup_probe.value.tcpSocket] : []
              content {
                port = tcp_socket.value.port
              }
            }

            dynamic "grpc" {
              for_each = startup_probe.value.grpc != null ? [startup_probe.value.grpc] : []
              content {
                port    = grpc.value.port
                service = grpc.value.service
              }
            }
          }
        }

        # Liveness probe (similar to livenessProbe in K8s)
        dynamic "liveness_probe" {
          for_each = containers.value.livenessProbe != null ? [containers.value.livenessProbe] : []
          content {
            initial_delay_seconds = liveness_probe.value.initialDelaySeconds
            timeout_seconds       = liveness_probe.value.timeoutSeconds
            period_seconds        = liveness_probe.value.periodSeconds
            failure_threshold     = liveness_probe.value.failureThreshold

            dynamic "http_get" {
              for_each = liveness_probe.value.httpGet != null ? [liveness_probe.value.httpGet] : []
              content {
                path = http_get.value.path
                port = http_get.value.port
                dynamic "http_headers" {
                  for_each = liveness_probe.value.httpHeaders != null ? liveness_probe.value.httpHeaders : []
                  content {
                    name  = http_headers.value.name
                    value = http_headers.value.value
                  }
                }
              }
            }

            dynamic "tcp_socket" {
              for_each = liveness_probe.value.tcpSocket != null ? [liveness_probe.value.tcpSocket] : []
              content {
                port = tcp_socket.value.port
              }
            }

            dynamic "grpc" {
              for_each = liveness_probe.value.grpc != null ? [liveness_probe.value.grpc] : []
              content {
                port    = grpc.value.port
                service = grpc.value.service
              }
            }
          }
        }

        # Readiness probe (similar to readinessProbe in K8s)
        dynamic "startup_probe" {
          for_each = containers.value.readinessProbe != null ? [containers.value.readinessProbe] : []
          content {
            initial_delay_seconds = startup_probe.value.initialDelaySeconds
            timeout_seconds       = startup_probe.value.timeoutSeconds
            period_seconds        = startup_probe.value.periodSeconds
            failure_threshold     = startup_probe.value.failureThreshold

            dynamic "http_get" {
              for_each = startup_probe.value.httpGet != null ? [startup_probe.value.httpGet] : []
              content {
                path = http_get.value.path
                port = http_get.value.port
                dynamic "http_headers" {
                  for_each = startup_probe.value.httpHeaders != null ? startup_probe.value.httpHeaders : []
                  content {
                    name  = http_headers.value.name
                    value = http_headers.value.value
                  }
                }
              }
            }

            dynamic "tcp_socket" {
              for_each = startup_probe.value.tcpSocket != null ? [startup_probe.value.tcpSocket] : []
              content {
                port = tcp_socket.value.port
              }
            }

            dynamic "grpc" {
              for_each = startup_probe.value.grpc != null ? [startup_probe.value.grpc] : []
              content {
                port    = grpc.value.port
                service = grpc.value.service
              }
            }
          }
        }
      }
    }
  }

  # Traffic configuration (similar to service selector in K8s)
  dynamic "traffic" {
    for_each = local.merged_traffic
    content {
      type     = traffic.value.type
      revision = traffic.value.revision
      percent  = traffic.value.percent
      tag      = traffic.value.tag
    }
  }

  # Ingress configuration
  ingress = local.merged_ingress

  # Binary authorization
  dynamic "binary_authorization" {
    for_each = local.merged_binary_authorization != null ? [local.merged_binary_authorization] : []
    content {
      use_default              = binary_authorization.value.useDefault
      breakglass_justification = binary_authorization.value.breakglassJustification
    }
  }

  # Lifecycle
  lifecycle {
    ignore_changes = [
      template[0].annotations["run.googleapis.com/operation-id"],
      template[0].annotations["serving.knative.dev/creator"],
      template[0].annotations["serving.knative.dev/lastModifier"],
      template[0].annotations["run.googleapis.com/client-name"],
      template[0].annotations["run.googleapis.com/client-version"],
    ]
  }
}
