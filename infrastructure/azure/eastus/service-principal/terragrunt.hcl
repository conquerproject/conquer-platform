locals {
  az-eastus-constants = yamldecode(file("../az-eastus-constants.yaml"))
  global-constants    = yamldecode(file("../../../global-constants.yaml"))
}

inputs = {
  app_name = "conquerproject-gitops"

  owners = local.global-constants.maintainers

  subjects = [
    "repo:conquerproject/conquer-plataform:ref:refs/heads/main",
    "repo:conquerproject/conquer-plataform:pull_request",
  ]

  permissions = {
    "/subscriptions/907cde31-ecc8-45c6-adb3-3c86455c885b" = [
      "Contributor",
    ],

  }
}

terraform {
  source = "git::https://github.com/conquerproject/tf-modules.git//service-principal?ref=service-principal-v0.1.0"
}

include "tg_shared_configs" {
  path = find_in_parent_folders("tg-shared-configs.hcl")
}
