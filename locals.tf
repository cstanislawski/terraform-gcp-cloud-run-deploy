# Parse manifest file if provided
locals {
  # Load and parse the manifest file
  manifest_content = var.manifest_path != null ? yamldecode(file(var.manifest_path)) : {}

  # Extract values from manifest with proper defaults
  manifest_metadata = try(local.manifest_content.metadata, {})
  manifest_spec     = try(local.manifest_content.spec, {})
  manifest_template = try(local.manifest_spec.template, {})

  # Merge metadata (direct params override manifest)
  merged_metadata = {
    name     = coalesce(try(var.metadata.name, null), try(local.manifest_metadata.name, null))
    location = coalesce(try(var.metadata.location, null), try(local.manifest_metadata.location, null))
    project  = coalesce(try(var.metadata.project, null), try(local.manifest_metadata.project, null))
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
  }

  # Get containers from manifest and module
  manifest_containers = try(local.manifest_template.spec.containers, [])
  module_containers   = try(var.template.spec.containers, [])

  # Merge containers by name - module containers override manifest containers
  # If module containers are provided, merge them with manifest containers by name
  # If no module containers, use manifest containers as-is
  merged_containers = length(local.module_containers) > 0 ? [
    for manifest_container in local.manifest_containers :
    contains([for mc in local.module_containers : mc.name], manifest_container.name) ?
    merge(
      manifest_container,
      [for mc in local.module_containers : mc if mc.name == manifest_container.name][0]
    ) : manifest_container
  ] : local.manifest_containers

  # Merge template spec (direct params override manifest)
  merged_template_spec = {
    serviceAccountName   = coalesce(try(var.template.spec.serviceAccountName, null), try(local.manifest_template.spec.serviceAccountName, null))
    executionEnvironment = coalesce(try(var.template.spec.executionEnvironment, null), try(local.manifest_template.spec.executionEnvironment, null), "EXECUTION_ENVIRONMENT_GEN2")

    vpcAccess    = coalesce(try(var.template.spec.vpcAccess, null), try(local.manifest_template.spec.vpcAccess, null))
    nodeSelector = coalesce(try(var.template.spec.nodeSelector, null), try(local.manifest_template.spec.nodeSelector, null))

    volumes    = coalesce(try(var.template.spec.volumes, null), try(local.manifest_template.spec.volumes, null), [])
    containers = local.merged_containers
  }

  # Merge template
  merged_template = {
    metadata = local.merged_template_metadata
    spec     = local.merged_template_spec
  }

  # Merge traffic (direct params override manifest)
  merged_traffic = coalesce(
    var.traffic,
    try(local.manifest_content.traffic, null),
    [{
      type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
      percent = 100
    }]
  )

  # Merge ingress (direct params override manifest)
  merged_ingress = coalesce(
    var.ingress,
    try(local.manifest_content.ingress, null),
    "INGRESS_TRAFFIC_ALL"
  )

  # Merge binary authorization (direct params override manifest)
  merged_binary_authorization = coalesce(
    var.binaryAuthorization,
    try(local.manifest_content.binaryAuthorization, null)
  )

  # Validation
  final_metadata = local.merged_metadata.name != null && local.merged_metadata.location != null ? local.merged_metadata : null
  final_template = length(local.merged_template_spec.containers) > 0 ? local.merged_template : null
}
