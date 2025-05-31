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
  normalize_container = { for container in concat(
    try(local.manifest_template.spec.containers, []),
    try(var.template.spec.containers, [])
  ) : container.name => {
    name         = container.name
    image        = try(container.image, null)
    command      = try(container.command, null)
    args         = try(container.args, null)
    workingDir   = try(container.workingDir, null)
    env          = try(container.env, null)
    resources    = try(container.resources, null) != null ? {
      limits = try(container.resources.limits, {})
      cpuIdle = try(container.resources.cpuIdle, null)
      startupCpuBoost = try(container.resources.startupCpuBoost, null)
    } : null
    ports           = try(container.ports, null) != null ? [
      for port in container.ports : {
        name          = try(port.name, null)
        containerPort = port.containerPort
      }
    ] : null
    volumeMounts    = try(container.volumeMounts, null)
    startupProbe    = try(container.startupProbe, null)
    livenessProbe   = try(container.livenessProbe, null)
    readinessProbe  = try(container.readinessProbe, null)
  }}

  # Get containers from manifest and module
  manifest_containers = try(local.manifest_template.spec.containers, [])
  module_containers   = try(var.template.spec.containers, [])

  # Merge containers by name - module containers override manifest containers
  # Use normalized containers
  merged_containers = length(local.module_containers) > 0 ? [
    for container_name, container in local.normalize_container : container
  ] : [
    for container_name, container in local.normalize_container : container
  ]

  # Merge template spec (direct params override manifest)
  merged_template_spec = {
    serviceAccountName   = try(var.template.spec.serviceAccountName, null) != null ? var.template.spec.serviceAccountName : try(local.manifest_template.spec.serviceAccountName, null)
    executionEnvironment = coalesce(try(var.template.spec.executionEnvironment, null), try(local.manifest_template.spec.executionEnvironment, null), "EXECUTION_ENVIRONMENT_GEN2")

    vpcAccess    = try(var.template.spec.vpcAccess, null) != null ? var.template.spec.vpcAccess : try(local.manifest_template.spec.vpcAccess, null)
    nodeSelector = try(var.template.spec.nodeSelector, null) != null ? var.template.spec.nodeSelector : try(local.manifest_template.spec.nodeSelector, null)

    volumes    = coalesce(try(var.template.spec.volumes, null), try(local.manifest_template.spec.volumes, null), [])
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
