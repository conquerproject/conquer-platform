
output "identities" {
  description = "Identities info"
  value = {
    for name in var.identities :
    name => {
      client_id = azurerm_user_assigned_identity.identity[name].client_id
    }
  }
}
