locals {
  az-eastus-constants = yamldecode(file("../az-eastus-constants.yaml"))
  global-constants = yamldecode(file("../../../global-constants.yaml"))
}

inputs = {
  vnet_name           = "vnet-conquerplatform-dev-001"
  resource_group_name = local.az-eastus-constants.default_dev_rg
  vnet_address_space  = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = "Default"
  location            = local.az-eastus-constants.region
}

terraform {
   source = "git::https://github.com/conquerproject/tf-modules.git//azure-vnet?ref=azure-vnet-v0.1.0" 
#   source = "../../../../../tf-modules/azure-vnet/"
}

include "tg_shared_configs" {
  path = find_in_parent_folders("tg-shared-configs.hcl")
}