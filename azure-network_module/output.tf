# -
# - Network - List outputs
# -

output "vnet_ids" {
  value = [for x in azurerm_virtual_network.vnets : x.id]
}

output "vnet_names" {
  value = [for x in azurerm_virtual_network.vnets : x.name]
}

output "vnet_locations" {
  value = [for x in azurerm_virtual_network.vnets : x.location]
}

output "vnet_rgnames" {
  value = [for x in azurerm_virtual_network.vnets : x.resource_group_name]
}

output "subnet_ids" {
  value = [for x in azurerm_subnet.subnets : x.id]

}
output "network_security_group_ids" {
  value = [for x in azurerm_network_security_group.nsgs : x.id]
}
output "route_table_ids" {
  value = [for x in azurerm_route_table.rts : x.id]
}

output "public_ip_ids" {
  value = [for x in azurerm_public_ip.pips : x.id]
}

# -
# - Network - Map outputs
# -
locals {
  vnets_keys = keys(var.virtual_networks)
  vnets_values = [for x in azurerm_virtual_network.vnets : {
    id                  = x.id
    name                = x.name
    location            = x.location
    resource_group_name = x.resource_group_name
  }]
  vnets = zipmap(local.vnets_keys, local.vnets_values)

  subnets_keys = keys(var.subnets)
  subnets_values = [for x in azurerm_subnet.subnets : {
    id = x.id
  }]
  subnets = zipmap(local.subnets_keys, local.subnets_values)
}

output "vnets" {
  value = local.vnets
}
output "subnets" {
  value = local.subnets
}
