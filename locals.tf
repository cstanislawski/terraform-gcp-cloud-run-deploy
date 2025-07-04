# Parse manifest file if provided
locals {
  # Load and parse the manifest file if provided (only for K8s-like config)
  raw_manifest_content = var.manifest_path != null ? yamldecode(file(var.manifest_path)) : null

  # Extract values from manifest with proper defaults
  manifest_metadata = try(local.raw_manifest_content.metadata, {})
  manifest_spec     = try(local.raw_manifest_content.spec, {})
  manifest_template = try(local.manifest_spec.template, {})

  # Merge metadata (direct params override manifest)
  merged_metadata = {
    name     = try(var.metadata.name, null) != null ? var.metadata.name : try(local.manifest_metadata.name, null)
    location = try(var.metadata.location, null) != null ? var.metadata.location : try(local.manifest_metadata.location, null)
    project  = try(var.metadata.project, null) != null ? var.metadata.project : try(local.manifest_metadata.project, null)
  }

  # Merge spec (direct params override manifest)
  merged_spec = {
    replicas = coalesce(try(var.spec.replicas, null), try(local.manifest_spec.replicas, null), 1)
  }

  # Merge template metadata - module parameters override manifest values as it's the last one to be merged
  merged_template_metadata = {
    labels = merge(
      try(local.manifest_template.metadata.labels, {}),
      try(var.template.metadata.labels, {})
    )
    annotations = merge(
      try(local.manifest_template.metadata.annotations, {}),
      try(var.template.metadata.annotations, {})
    )
  }

  # Normalize containers to ensure all have expected attributes
  # First normalize manifest containers
  manifest_containers_normalized = { for container in try(local.manifest_template.spec.containers, []) : container.name => {
    name       = container.name
    image      = try(container.image, null)
    command    = try(container.command, null)
    args       = try(container.args, null)
    workingDir = try(container.workingDir, null)
    env        = try(container.env, null)
    resources = try(container.resources, null) != null ? {
      limits = {
        cpu    = try(container.resources.limits.cpu, "1000m")
        memory = try(container.resources.limits.memory, "512Mi")
      }
      cpuIdle         = try(container.resources.cpuIdle, true)
      startupCpuBoost = try(container.resources.startupCpuBoost, false)
      } : {
      limits = {
        cpu    = "1000m"
        memory = "512Mi"
      }
      cpuIdle         = true
      startupCpuBoost = false
    }
    ports = try(container.ports, null) != null ? [
      for port in container.ports : {
        name          = try(port.name, null)
        containerPort = port.containerPort
      }
    ] : null
    volumeMounts = try(container.volumeMounts, null)
    startupProbe = try(container.startupProbe, null) != null ? {
      initialDelaySeconds = try(container.startupProbe.initialDelaySeconds, 0)
      timeoutSeconds      = try(container.startupProbe.timeoutSeconds, 1)
      periodSeconds       = try(container.startupProbe.periodSeconds, 10)
      failureThreshold    = try(container.startupProbe.failureThreshold, 3)
      httpGet = try(container.startupProbe.httpGet, null) != null ? {
        path        = try(container.startupProbe.httpGet.path, "/")
        port        = try(container.startupProbe.httpGet.port, 8080)
        httpHeaders = try(container.startupProbe.httpGet.httpHeaders, null)
      } : null
      tcpSocket = try(container.startupProbe.tcpSocket, null) != null ? {
        port = try(container.startupProbe.tcpSocket.port, 8080)
      } : null
      grpc = try(container.startupProbe.grpc, null) != null ? {
        port    = try(container.startupProbe.grpc.port, 8080)
        service = try(container.startupProbe.grpc.service, null)
      } : null
    } : null
    livenessProbe = try(container.livenessProbe, null) != null ? {
      initialDelaySeconds = try(container.livenessProbe.initialDelaySeconds, 0)
      timeoutSeconds      = try(container.livenessProbe.timeoutSeconds, 1)
      periodSeconds       = try(container.livenessProbe.periodSeconds, 10)
      failureThreshold    = try(container.livenessProbe.failureThreshold, 3)
      httpGet = try(container.livenessProbe.httpGet, null) != null ? {
        path        = try(container.livenessProbe.httpGet.path, "/")
        port        = try(container.livenessProbe.httpGet.port, 8080)
        httpHeaders = try(container.livenessProbe.httpGet.httpHeaders, null)
      } : null
      tcpSocket = try(container.livenessProbe.tcpSocket, null) != null ? {
        port = try(container.livenessProbe.tcpSocket.port, 8080)
      } : null
      grpc = try(container.livenessProbe.grpc, null) != null ? {
        port    = try(container.livenessProbe.grpc.port, 8080)
        service = try(container.livenessProbe.grpc.service, null)
      } : null
    } : null
    readinessProbe = try(container.readinessProbe, null) != null ? {
      initialDelaySeconds = try(container.readinessProbe.initialDelaySeconds, 0)
      timeoutSeconds      = try(container.readinessProbe.timeoutSeconds, 1)
      periodSeconds       = try(container.readinessProbe.periodSeconds, 10)
      failureThreshold    = try(container.readinessProbe.failureThreshold, 3)
      httpGet = try(container.readinessProbe.httpGet, null) != null ? {
        path        = try(container.readinessProbe.httpGet.path, "/")
        port        = try(container.readinessProbe.httpGet.port, 8080)
        httpHeaders = try(container.readinessProbe.httpGet.httpHeaders, null)
      } : null
      tcpSocket = try(container.readinessProbe.tcpSocket, null) != null ? {
        port = try(container.readinessProbe.tcpSocket.port, 8080)
      } : null
      grpc = try(container.readinessProbe.grpc, null) != null ? {
        port    = try(container.readinessProbe.grpc.port, 8080)
        service = try(container.readinessProbe.grpc.service, null)
      } : null
    } : null
  } }

  # Then normalize module containers
  module_containers_normalized = { for container in try(var.template.spec.containers, []) : container.name => {
    name       = container.name
    image      = try(container.image, null)
    command    = try(container.command, null)
    args       = try(container.args, null)
    workingDir = try(container.workingDir, null)
    env        = try(container.env, null)
    resources = try(container.resources, null) != null ? {
      limits = {
        cpu    = try(container.resources.limits.cpu, "1000m")
        memory = try(container.resources.limits.memory, "512Mi")
      }
      cpuIdle         = try(container.resources.cpuIdle, true)
      startupCpuBoost = try(container.resources.startupCpuBoost, false)
    } : null
    ports = try(container.ports, null) != null ? [
      for port in container.ports : {
        name          = try(port.name, null)
        containerPort = port.containerPort
      }
    ] : null
    volumeMounts   = try(container.volumeMounts, null)
    startupProbe   = try(container.startupProbe, null)
    livenessProbe  = try(container.livenessProbe, null)
    readinessProbe = try(container.readinessProbe, null)
  } }

  # Merge containers: module containers override manifest containers
  all_containers_normalized = merge(
    local.manifest_containers_normalized,
    {
      for container_name, module_container in local.module_containers_normalized :
      container_name => merge(
        try(local.manifest_containers_normalized[container_name], {}),
        # Only include non-null values from module container
        {
          for k, v in module_container : k => v if v != null
        }
      )
    }
  )

  # Get containers from manifest and module
  manifest_containers = try(local.manifest_template.spec.containers, [])
  module_containers   = try(var.template.spec.containers, [])

  # Convert the merged containers map back to a list
  merged_containers = [for container_name, container in local.all_containers_normalized : container]

  # Handle volumes with consistent types
  manifest_volumes = try([for v in local.manifest_template.spec.volumes : v], [])
  module_volumes   = try(var.template.spec.volumes, [])

  # Merge template spec (direct params override manifest)
  merged_template_spec = {
    serviceAccountName   = try(var.template.spec.serviceAccountName, null) != null ? var.template.spec.serviceAccountName : try(local.manifest_template.spec.serviceAccountName, null)
    executionEnvironment = coalesce(try(var.template.spec.executionEnvironment, null), try(local.manifest_template.spec.executionEnvironment, null), "EXECUTION_ENVIRONMENT_GEN2")

    vpcAccess    = try(var.template.spec.vpcAccess, null) != null ? var.template.spec.vpcAccess : try(local.manifest_template.spec.vpcAccess, null)
    nodeSelector = try(var.template.spec.nodeSelector, null) != null ? var.template.spec.nodeSelector : try(local.manifest_template.spec.nodeSelector, null)

    volumes = length(try(var.template.spec.volumes, [])) > 0 ? var.template.spec.volumes : (
      try(local.manifest_template.spec.volumes, null) != null ? [for v in local.manifest_template.spec.volumes : {
        name = v.name
        secret = try(v.secret, null) != null ? {
          secretName  = try(v.secret.secretName, "")
          defaultMode = try(v.secret.defaultMode, 0644)
          items       = try(v.secret.items, [])
        } : null
        cloudSqlInstance = try(v.cloudSqlInstance, null)
        emptyDir = try(v.emptyDir, null) != null ? {
          medium    = try(v.emptyDir.medium, "MEMORY")
          sizeLimit = try(v.emptyDir.sizeLimit, null)
        } : null
      }] : []
    )
    containers = local.merged_containers
  }

  # Merge template
  merged_template = {
    metadata = local.merged_template_metadata
    spec     = local.merged_template_spec
  }

  # Cloud Run specific configuration (only from module variables)
  # Traffic configuration - normalize to ensure all attributes are present
  merged_traffic = var.traffic != null ? [
    for traffic_rule in var.traffic : {
      type     = try(traffic_rule.type, "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST")
      revision = try(traffic_rule.revision, null)
      percent  = try(traffic_rule.percent, 100)
      tag      = try(traffic_rule.tag, null)
    }
    ] : [{
      type     = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
      revision = null
      percent  = 100
      tag      = null
  }]

  # Ingress configuration (only from module variables)
  merged_ingress = coalesce(var.ingress, "INGRESS_TRAFFIC_ALL")

  # Binary authorization (only from module variables)
  merged_binary_authorization = var.binaryAuthorization

  # Validation
  final_metadata = local.merged_metadata.name != null && local.merged_metadata.location != null ? local.merged_metadata : null
  final_template = length(local.merged_template_spec.containers) > 0 ? local.merged_template : null
}
