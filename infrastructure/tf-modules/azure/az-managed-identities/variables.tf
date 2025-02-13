variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "identities" {
  description = "AZ Managed Identity name"
  type = list(object({
    name = string
    role = string
  }))
}

variable "rg" {
  description = "Resource Group Name"
  type        = string
}

variable "tags" {
  description = "Resource Tags"
  type        = map(string)
}
