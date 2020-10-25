# -
# - Terraform's modules : rules of the game --> https://www.terraform.io/docs/modules/index.html
# -

# -
# - Data gathering
# -
data "azurerm_resource_group" "network" {
  name = var.network_resource_group_name
}

locals {
  location = var.net_location == "" ? data.azurerm_resource_group.network.location : var.net_location
  tags     = merge(var.net_additional_tags, data.azurerm_resource_group.network.tags)
}

/*
#Data source feature request in progress : https://github.com/terraform-providers/terraform-provider-azurerm/issues/3851
data "azurerm_network_ddos_protection_plan" "one" {
  name                = var.network_ddos_protection_plan["name"]
  resource_group_name = var.network_ddos_protection_plan["resource_group_name"]
}
*/

# -
# - Network
# -

resource "azurerm_virtual_network" "vnets" {
  for_each            = var.virtual_networks
  name                = "${var.net_prefix}-${each.value["prefix"]}-vnet${each.value["id"]}"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.network.name
  address_space       = each.value["address_space"]
  dns_servers         = lookup(each.value, "dns_servers", null)

  dynamic "ddos_protection_plan" {
    for_each = var.network_ddos_protection_plan
    content {
      id     = lookup(ddos_protection_plan.value, "id", null)
      enable = lookup(ddos_protection_plan.value, "enable", false)
    }
  }

  tags = local.tags
}

# -
# - Subnet
# -

resource "azurerm_subnet" "subnets" {
  for_each                  = var.subnets
  name                      = each.value["name"]
  resource_group_name       = data.azurerm_resource_group.network.name
  address_prefix            = each.value["address_prefix"]
  service_endpoints         = lookup(each.value, "service_endpoints", null)
  route_table_id            = lookup(each.value, "rt_key", null) == null ? null : lookup(azurerm_route_table.rts, each.value["rt_key"], null)["id"]
  network_security_group_id = lookup(each.value, "nsg_key", null) == null ? null : lookup(azurerm_network_security_group.nsgs, each.value["nsg_key"], null)["id"]

  /*
  This forces a destroy when adding a new vnet -->
  virtual_network_name      = lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]

  Workaround -->
  */
  depends_on           = [azurerm_virtual_network.vnets]
  virtual_network_name = "${var.net_prefix}-${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_vnets")["prefix"]}-vnet${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_vnets")["id"]}"

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", [])
    content {
      name = lookup(delegation.value, "name", null)
      dynamic "service_delegation" {
        for_each = lookup(delegation.value, "service_delegation", [])
        content {
          name    = lookup(service_delegation.value, "name", null)    # (Required) The name of service to delegate to. Possible values include Microsoft.BareMetal/AzureVMware, Microsoft.BareMetal/CrayServers, Microsoft.Batch/batchAccounts, Microsoft.ContainerInstance/containerGroups, Microsoft.Databricks/workspaces, Microsoft.HardwareSecurityModules/dedicatedHSMs, Microsoft.Logic/integrationServiceEnvironments, Microsoft.Netapp/volumes, Microsoft.ServiceFabricMesh/networks, Microsoft.Sql/managedInstances, Microsoft.Sql/servers, Microsoft.Web/hostingEnvironments and Microsoft.Web/serverFarms.
          actions = lookup(service_delegation.value, "actions", null) # (Required) A list of Actions which should be delegated. Possible values include Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action, Microsoft.Network/virtualNetworks/subnets/action and Microsoft.Network/virtualNetworks/subnets/join/action.
        }
      }
    }
  }
}

# -
# - Route Table
# -
resource "azurerm_route_table" "rts" {
  for_each                      = var.route_tables
  name                          = "${var.net_prefix}-rt${each.value["id"]}"
  location                      = local.location
  resource_group_name           = data.azurerm_resource_group.network.name
  disable_bgp_route_propagation = lookup(each.value, "disable_bgp_route_propagation", null)

  dynamic "route" {
    for_each = lookup(each.value, "routes", null)
    content {
      name                   = lookup(route.value, "name", null)
      address_prefix         = lookup(route.value, "address_prefix", null)
      next_hop_type          = lookup(route.value, "next_hop_type", null)
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }
  tags = local.tags
}

locals {
  subnet_names_with_route_table = [for x in var.subnets : "${x.vnet_key}_${x.name}" if lookup(x, "rt_key", "null") != "null"]
  subnet_rt_keys_with_route_table = [for x in var.subnets : {
    subnet_name = x.name
    rt_key      = x.rt_key
    vnet_key    = x.vnet_key
  } if lookup(x, "rt_key", "null") != "null"]
  subnets_with_route_table = zipmap(local.subnet_names_with_route_table, local.subnet_rt_keys_with_route_table)
}

resource "azurerm_subnet_route_table_association" "route_table_associations" {
  for_each       = local.subnets_with_route_table
  route_table_id = lookup(azurerm_route_table.rts, each.value["rt_key"], null)["id"]

  /*
  This forces a destroy when adding a new vnet -->
  subnet_id = [for x in azurerm_subnet.subnets : x.id if
    x.name == each.value["subnet_name"]
    &&
    x.virtual_network_name == lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]
  ][0]

  Workaround -->
  */
  subnet_id = [for x in azurerm_subnet.subnets : x.id if
    x.name == each.value["subnet_name"]
    &&
    x.virtual_network_name == "${var.net_prefix}-${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_subnets")["prefix"]}-vnet${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_subnets")["id"]}"
  ][0]
}

# -
# - Network Security Group
# -

resource "azurerm_network_security_group" "nsgs" {
  for_each            = var.network_security_groups
  name                = "${var.net_prefix}-nsg${each.value["id"]}"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.network.name

  dynamic "security_rule" {
    for_each = each.value["security_rules"]
    content {
      description                  = lookup(security_rule.value, "description", null)
      direction                    = lookup(security_rule.value, "direction", null)
      name                         = lookup(security_rule.value, "name", null)
      access                       = lookup(security_rule.value, "access", null)
      priority                     = lookup(security_rule.value, "priority", null)
      source_address_prefix        = lookup(security_rule.value, "source_address_prefix", null)
      source_address_prefixes      = lookup(security_rule.value, "source_address_prefixes", null)
      destination_address_prefix   = lookup(security_rule.value, "destination_address_prefix", null)
      destination_address_prefixes = lookup(security_rule.value, "destination_address_prefixes", null)
      destination_port_range       = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges      = lookup(security_rule.value, "destination_port_ranges", null)
      protocol                     = lookup(security_rule.value, "protocol", null)
      source_port_range            = lookup(security_rule.value, "source_port_range", null)
      source_port_ranges           = lookup(security_rule.value, "source_port_ranges", null)
    }
  }
  tags = local.tags
}

locals {
  subnet_names_network_security_group = [for x in var.subnets : "${x.vnet_key}_${x.name}" if lookup(x, "nsg_key", "null") != "null"]
  subnet_nsg_keys_network_security_group = [for x in var.subnets : {
    subnet_name = x.name
    nsg_key     = x.nsg_key
    vnet_key    = x.vnet_key
  } if lookup(x, "nsg_key", "null") != "null"]
  subnets_network_security_group = zipmap(local.subnet_names_network_security_group, local.subnet_nsg_keys_network_security_group)
}

resource "azurerm_subnet_network_security_group_association" "security_group_associations" {
  for_each                  = local.subnets_network_security_group
  network_security_group_id = lookup(azurerm_network_security_group.nsgs, each.value["nsg_key"], null)["id"]

  /*
  This forces a destroy when adding a new vnet -->
  subnet_id = [for x in azurerm_subnet.subnets : x.id if
    x.name == each.value["subnet_name"]
    &&
    x.virtual_network_name == lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]
  ][0]

  Workaround -->
  */
  subnet_id = [for x in azurerm_subnet.subnets : x.id if
    x.name == each.value["subnet_name"]
    &&
    x.virtual_network_name == "${var.net_prefix}-${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_subnets")["prefix"]}-vnet${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_subnets")["id"]}"
  ][0]
}

# -
# - Bastion
# -

locals {
  subnets_with_bastion_key = [for x in var.subnets : "${x.vnet_key}_${x.name}" if x.name == "AzureBastionSubnet"]
  subnets_with_bastion_value = [for x in var.subnets : {
    subnet_name    = x.name
    address_prefix = x.address_prefix
    vnet_key       = x.vnet_key
  } if x.name == "AzureBastionSubnet"]
  subnets_with_bastion = zipmap(local.subnets_with_bastion_key, local.subnets_with_bastion_value)
}


/*
#Old method before azurerm 1.36.0
#Using a template because the resource is not ready, feature request done here : https://github.com/terraform-providers/terraform-provider-azurerm/issues/3829
resource "azurerm_template_deployment" "bastion" {
  depends_on          = [azurerm_subnet.subnets]
  for_each            = local.subnets_with_bastion
  name                = "${lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]}-bas1-dep"
  resource_group_name = data.azurerm_resource_group.network.name
  template_body = file(
    "${path.module}/AzureRmBastion_template.json",
  )
  deployment_mode = "Incremental"

  parameters = {
    location            = local.location
    resourceGroupName   = data.azurerm_resource_group.network.name
    lb_public_ip_id     = var.bas_lb_public_ip_id
    bastionHostName     = "${lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]}-bas1"
    subnetName          = each.value["subnet_name"]
    publicIpAddressName = "${lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]}-bas1-pip1"
    existingVNETName    = "${lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]}"
    subnetAddressPrefix = each.value["address_prefix"]
    tags                = jsonencode(local.tags)
  }
}
*/
resource "azurerm_public_ip" "bastions" {
  depends_on          = [azurerm_subnet.subnets]
  for_each            = local.subnets_with_bastion
  name                = "${lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]}-bas1-pip1"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.network.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_bastion_host" "bastions" {
  depends_on          = [azurerm_subnet.subnets]
  for_each            = local.subnets_with_bastion
  name                = "${lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]}-bas1"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.network.name

  ip_configuration {
    name = "${lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]}-bas1-CFG"
    subnet_id = [for x in azurerm_subnet.subnets : x.id if
      x.name == each.value["subnet_name"]
      &&
      x.virtual_network_name == "${var.net_prefix}-${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_subnets")["prefix"]}-vnet${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_subnets")["id"]}"
    ][0]
    public_ip_address_id = [for x in azurerm_public_ip.bastions : x.id if
      x.name == "${lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]}-bas1-pip1"
    ][0]
  }
  tags = local.tags
}

# -
# - Public Ip
# -

resource "azurerm_public_ip" "pips" {
  for_each                = var.pips
  name                    = "${var.net_prefix}-${each.value["prefix"]}-pip${each.value["id"]}"
  location                = local.location
  resource_group_name     = data.azurerm_resource_group.network.name
  sku                     = lookup(each.value, "sku", "Basic")
  allocation_method       = lookup(each.value, "allocation_method", "Static")
  ip_version              = lookup(each.value, "ip_version", "IPv4")
  idle_timeout_in_minutes = lookup(each.value, "idle_timeout_in_minutes", null)
  domain_name_label       = lookup(each.value, "domain_name_label", null)
  reverse_fqdn            = lookup(each.value, "reverse_fqdn", null)
  zones                   = lookup(each.value, "zones", null)
  tags                    = local.tags
}

# -
# - Virtual Network Peering
# -

data "azurerm_subscription" "current" {}

resource "azurerm_virtual_network_peering" "peers" {
  for_each                     = var.vnets_to_peer
  resource_group_name          = data.azurerm_resource_group.network.name
  remote_virtual_network_id    = lookup(each.value, "remote_subscription_id", "null") == "null" ? "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${each.value["remote_vnet_rg_name"]}/providers/Microsoft.Network/virtualNetworks/${each.value["remote_vnet_name"]}" : "/subscriptions/${each.value["remote_subscription_id"]}/resourceGroups/${each.value["remote_vnet_rg_name"]}/providers/Microsoft.Network/virtualNetworks/${each.value["remote_vnet_name"]}"
  allow_virtual_network_access = lookup(each.value, "allow_virtual_network_access", null) #(Optional) Controls if the VMs in the remote virtual network can access VMs in the local virtual network. Defaults to false.
  allow_forwarded_traffic      = lookup(each.value, "allow_forwarded_traffic", null)      #(Optional) Controls if forwarded traffic from VMs in the remote virtual network is allowed. Defaults to false.
  allow_gateway_transit        = lookup(each.value, "allow_gateway_transit", null)        #(Optional) Controls gatewayLinks can be used in the remote virtual network’s link to the local virtual network.
  use_remote_gateways          = lookup(each.value, "use_remote_gateways", null)          #(Optional) Controls if remote gateways can be used on the local virtual network. If the flag is set to true, and allow_gateway_transit on the remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway. Defaults to false.

  /*
  This forces a destroy when adding a new vnet -->
  name                         = "${lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]}_to_${each.value["remote_vnet_name"]}"
  virtual_network_name         = lookup(azurerm_virtual_network.vnets, each.value["vnet_key"], null)["name"]

  Workaround -->
  */
  depends_on           = [azurerm_virtual_network.vnets]
  name                 = "${var.net_prefix}-${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_vnets_to_peer")["prefix"]}-vnet${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_vnets_to_peer")["id"]}_to_${each.value["remote_vnet_name"]}"
  virtual_network_name = "${var.net_prefix}-${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_vnets_to_peer")["prefix"]}-vnet${lookup(var.virtual_networks, each.value["vnet_key"], "wrong_vnet_key_in_vnets_to_peer")["id"]}"
}
