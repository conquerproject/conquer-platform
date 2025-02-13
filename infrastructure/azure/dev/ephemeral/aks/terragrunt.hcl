terraform {
  source = "${get_repo_root()}//infrastructure/tf-modules/azure/aks"
}

include "tg-shared-configs" {
  path = find_in_parent_folders("tg-shared-configs.hcl")
}

locals {
  global-constants = yamldecode(
    file("${get_repo_root()}//infrastructure/global-constants.yaml")
  )
  environment-constants = yamldecode(
    file("${get_repo_root()}//infrastructure/azure/dev/constants.yaml")
  )
}

inputs = {
  resource_group_name = local.environment-constants.default_rg
  aks_name            = "aks-${local.global-constants.global-tags.project}-${local.environment-constants.environment}-01"
  location            = local.environment-constants.region
  node_pool_vm_size   = "Standard_B2s"
  node_pool_count     = 2
  k8s_version         = "1.29"
  network_plugin      = "azure"
  network_plugin_mode = "overlay"
  tags = merge(
    local.environment-constants.tags,
    local.global-constants.global-tags
  )
}
