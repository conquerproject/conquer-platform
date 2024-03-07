locals {
  az-eastus-constants = yamldecode(file("../az-eastus-constants.yaml"))
  global-constants = yamldecode(file("../../../global-constants.yaml"))
}

inputs = {
  location = local.az-eastus-constants.region
  #resource_group_name = "rg-${local.global-constants.project}-${local.az-eastus-constants.environment}-001"
  resource_group_name = local.az-eastus-constants.default_dev_rg
}


terraform {
#  source = "git::https://github.com/conquerproject/tf-modules.git/azure-resource-group?ref=azure-resource-group-v0.1.0" 
  source = "../../../../../tf-modules/azure-resource-group/"
}

include "tg_shared_configs" {
  path = find_in_parent_folders("tg-shared-configs.hcl")
}