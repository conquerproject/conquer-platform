generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      backend "azurerm" {
        resource_group_name = "rg-tfstate-dev-eastus-001"
        storage_account_name = "stgtfstatedeveastus001"
        container_name  = "tfstate"
        key = "${path_relative_to_include()}/terraform.tfstate"
      }
    } 
  EOF
}
