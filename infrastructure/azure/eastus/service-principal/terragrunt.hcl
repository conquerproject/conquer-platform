locals {
  az-eastus-constants = yamldecode(file("../az-eastus-constants.yaml"))
  global-constants = yamldecode(file("../../../global-constants.yaml"))
}

inputs = {
  app_name = "conquerproject-gitops"
 
  owners = local.global-constants.maintainers

  subjects = [
    "repo:conquerproject/conquer-platform:ref:refs/heads/main",
    "repo:conquerproject/conquer-platform:pull_request",
  ]
  
  permissions = {
     "/subscriptions/907cde31-ecc8-45c6-adb3-3c86455c885b" = [
      "Contributor",
     ],
  }
  
  required_resource_accesses = [
  {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph 
    resource_access = [
      {
        id   = "5b567255-7703-4780-807c-7be8301ae99b" # Group.Read.All
        type = "Role"
      },
      {
        id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
        type = "Role"
      },
      {
        id   = "18a4783c-866b-4cc7-a460-3d5e5662c884" # Application.ReadWrite.OwnedBy
        type = "Role"
      },
      {
        id   = "bf7b1a76-6e77-406b-b258-bf5c7720e98f" # Group.Create
        type = "Role"
      },
      {
        id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61" # Directory.Read.All
        type = "Role"
      }
    ]
  }
  ]
}

terraform {
  source = "/home/lhausch/my-repos/conquerproject/tf-modules/service-principal" # TODO: "git::https://github.com/conquerproject/tf-modules.git//service-principal?ref=service-principal-v0.1.0" 
}

include "tg_shared_configs" {
  path = find_in_parent_folders("tg-shared-configs.hcl")
}
