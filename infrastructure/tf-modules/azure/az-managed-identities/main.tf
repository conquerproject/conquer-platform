provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}



resource "azurerm_user_assigned_identity" "identity" {
  for_each            = var.identities
  name                = each.key
  location            = var.location
  resource_group_name = var.rg
  tags                = var.tags
}

#resource "azurerm_role_assignment" "role-assignment" {
#  scope                = var.subscription_id
#  role_definition_name = ""
#  principal_id         = data.azurerm_client_config.example.object_id
#}
#
