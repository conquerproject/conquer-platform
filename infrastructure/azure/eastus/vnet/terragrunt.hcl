locals {
  az-eastus-constants = yamldecode(file("../az-eastus-constants.yaml"))
  global-constants    = yamldecode(file("../../../global-constants.yaml"))
}

inputs = {
  vnet_name           = "vnet-conquerplatform-dev-001"
  resource_group_name = local.az-eastus-constants.default_dev_rg
  location            = local.az-eastus-constants.region
  vnet_address_space  = ["10.0.0.0/16"]
  subnets = {
    subnet-default = {
      name            = "Default"
      address_prefix  = ["10.0.1.0/24"]
    }
    subnet-k8s = {
      name            = "whatever, just testing"
      address_prefix  = ["10.0.2.0/24"]
    }
  }
  tags = {
    environment       = local.az-eastus-constants.tags.environment
    project           = local.global-constants.global-tags.project
    team              = local.global-constants.global-tags.team
    team-email        = local.global-constants.global-tags.team-email
  }
}


terraform {
   source = "git::https://github.com/conquerproject/tf-modules.git//azure-vnet?ref=azure-vnet-v0.1.0" 
#   source = "../../../../../tf-modules/azure-vnet/"
}

include "tg_shared_configs" {
  path = find_in_parent_folders("tg-shared-configs.hcl")
}

