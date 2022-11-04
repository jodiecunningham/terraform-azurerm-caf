# Terraform azurerm resource: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/iothub_dps

resource "azurecaf_name" "iothdps" {
  name          = var.settings.name
  resource_type = "azurerm_iothub_dps"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_iothub_dps" "iothubdps" {
  name                = azurecaf_name.iothdps.result
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_policy   = try(var.settings.allocation_policy, null)

  # requires azurerm provider >= 2.97.0
  public_network_access_enabled = try(var.settings.public_network_access_enabled, true)

  sku {
    name     = var.settings.sku.name
    capacity = var.settings.sku.capacity
  }

  dynamic "linked_hub" {
    for_each = lookup(var.settings, "linked_hub", {}) == {} ? [] : [1]
    content {
      connection_string       = var.settings.linked_hub.connection_string
      location                = var.settings.linked_hub.location
      apply_allocation_policy = try(var.settings.linked_hub.apply_allocation_policy, null)
      allocation_weight       = try(var.settings.linked_hub.allocation_weight, null)
      hostname                = try(var.settings.linked_hub.hostname, null)
    }
  }

  # requires azurerm provider >= 2.99.0
  dynamic "ip_filter_rule" {
    for_each = lookup(var.settings, "ip_filter_rule", {}) == {} ? [] : [1]
    content {
      name    = var.settings.ip_filter_rule.name
      ip_mask = var.settings.ip_filter_rule.ip_mask
      action  = var.settings.ip_filter_rule.action
      target  = try(var.settings.ip_filter_rule.target, null)
    }
  }

  tags = merge(local.tags, lookup(var.settings, "tags", {}))
}
