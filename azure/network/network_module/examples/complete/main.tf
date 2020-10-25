#Set the terraform backend
terraform {
  backend "azurerm" {
    storage_account_name = "infrasdbx1vpcjdld1"
    container_name       = "tfstate"
    key                  = "Az-VirtualNetwork.complete.tfstate"
    resource_group_name  = "infr-jdld-noprd-rg1"
  }
}

#Set the Provider
provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  version         = ">= 1.37.0" #1.36.0 to support the resource azurerm_bastion_host #1.37.0 fix a bug with the bastion host naming #With "=1.32.0" No warning with version the nsg and route linkd
}

#Set authentication variables
variable "tenant_id" {
  description = "Azure tenant Id."
}

variable "subscription_id" {
  description = "Azure subscription Id."
}

variable "client_id" {
  description = "Azure service principal application Id."
}

variable "client_secret" {
  description = "Azure service principal application Secret."
}

#Set resource variables
# -
# - Network object
# -
variable "virtual_networks" {
  default = {

    vnet1 = {
      id            = "1"
      prefix        = "npd"
      address_space = ["198.18.1.0/24", "198.18.2.0/24"]
    }

    vnet2 = {
      id            = "2"
      prefix        = "npd"
      address_space = ["198.18.4.0/24"]
      dns_servers   = ["8.8.8.8"]
    }

    vnet3 = {
      id            = "3"
      prefix        = "npd"
      address_space = ["10.0.0.0/24"]
    }
  }
}

variable "vnets_to_peer" {
  default = {
    vnets_to_peer1 = {
      vnet_key            = "vnet1"                   #(Mandatory)
      remote_vnet_name    = "product-perim-npd-vnet2" #(Mandatory)
      remote_vnet_rg_name = "infr-jdld-noprd-rg1"     #(Mandatory)
    }
    vnets_to_peer2 = {
      vnet_key            = "vnet2"                   #(Mandatory)
      remote_vnet_name    = "product-perim-npd-vnet1" #(Mandatory)
      remote_vnet_rg_name = "infr-jdld-noprd-rg1"     #(Mandatory)
      #remote_subscription_id = "43c91cd1-0bbf-40c0-9c3a-401b8dfd2dd3" #(Optional) use the current subscription if not provided
      #allow_virtual_network_access = ""                                     #(Optional) Controls if the VMs in the remote virtual network can access VMs in the local virtual network. Defaults to false.
      #allow_forwarded_traffic      = ""                                     #(Optional) Controls if forwarded traffic from VMs in the remote virtual network is allowed. Defaults to false.
      #allow_gateway_transit        = ""                                     #(Optional) Controls gatewayLinks can be used in the remote virtual network’s link to the local virtual network.
      #use_remote_gateways          = ""                                     #(Optional) Controls if remote gateways can be used on the local virtual network. If the flag is set to true, and allow_gateway_transit on the remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway. Defaults to false.
    }
  }
}

variable "subnets" {
  default = {
    snet1 = {
      vnet_key          = "vnet1"                                #(Mandatory)
      name              = "test1"                                #(Mandatory)
      address_prefix    = "198.18.1.0/26"                        #(Mandatory)
      nsg_key           = "nsg1"                                 #(Optional) delete this line for no NSG
      rt_key            = "rt1"                                  #(Optional) delete this line for no Route Table
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"] #(Optional) delete this line for no Service Endpoints
      delegation = [
        {
          name = "acctestdelegation" #(Required) A name for this delegation.
          service_delegation = [
            {
              name    = "Microsoft.ContainerInstance/containerGroups"        # (Required) The name of service to delegate to. Possible values include Microsoft.BareMetal/AzureVMware, Microsoft.BareMetal/CrayServers, Microsoft.Batch/batchAccounts, Microsoft.ContainerInstance/containerGroups, Microsoft.Databricks/workspaces, Microsoft.HardwareSecurityModules/dedicatedHSMs, Microsoft.Logic/integrationServiceEnvironments, Microsoft.Netapp/volumes, Microsoft.ServiceFabricMesh/networks, Microsoft.Sql/managedInstances, Microsoft.Sql/servers, Microsoft.Web/hostingEnvironments and Microsoft.Web/serverFarms.
              actions = ["Microsoft.Network/virtualNetworks/subnets/action"] # (Required) A list of Actions which should be delegated. Possible values include Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action, Microsoft.Network/virtualNetworks/subnets/action and Microsoft.Network/virtualNetworks/subnets/join/action.
            },
          ]
        },
      ]
    }

    snet2 = {
      vnet_key       = "vnet2"          #(Mandatory)
      name           = "test1"          #(Mandatory)
      address_prefix = "198.18.4.32/27" #(Mandatory)
      nsg_key        = "nsg1"           #(Optional) delete this line for no NSG
      rt_key         = "rt2"            #(Optional) delete this line for no Route Table
    }
    #/*
    #Issue on Bastion Host being solved here : https://social.msdn.microsoft.com/Forums/en-US/27e565ac-e71f-4172-8596-6d251b193b9d/cannot-deploy-azure-bastion?forum=WAVirtualMachinesVirtualNetwork
    snet3 = {
      vnet_key       = "vnet3"              #(Mandatory)
      name           = "AzureBastionSubnet" #(Mandatory)
      address_prefix = "10.0.0.0/27"        #(Mandatory)
    }
    #*/

  }
}
# -
# - Route Table
# -
variable "route_tables" {
  default = {
    rt1 = {
      id     = "1"
      routes = []
    }

    rt2 = {
      id = "2"
      routes = [
        {
          name           = "route1"
          address_prefix = "10.1.0.0/16"
          next_hop_type  = "vnetlocal"
        },
      ]
    }
  }
}
# -
# - Network Security Group
# -
variable "network_security_groups" {
  default = {
    nsg1 = {
      id = "1"
      security_rules = [
        {
          name                       = "test1"
          description                = "My Test 1"
          priority                   = 101
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                         = "test2"
          description                  = "My Test 2"
          priority                     = 102
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_range            = "*"
          destination_port_range       = "*"
          source_address_prefix        = "*"
          destination_address_prefixes = ["192.168.1.5", "192.168.1.6"]
        },
        {
          name                         = "test3"
          description                  = "My Test 3"
          priority                     = 103
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_range            = "*"
          destination_port_ranges      = ["22", "3389"]
          source_address_prefix        = "*"
          destination_address_prefixes = ["192.168.1.5", "192.168.1.6"]
        },
      ]
    }
  }
}

# -
# - Public Ip
# -

variable "pips" {
  default = {
    pip1 = {
      id                      = "1"
      prefix                  = "sec"
      sku                     = "Standard"    #(Optional) The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic.
      allocation_method       = "Static"      #(Optional) Default is Static
      ip_version              = "IPv4"        #(Optional) The IP Version to use, IPv6 or IPv4.
      idle_timeout_in_minutes = null          #(Optional) Specifies the timeout for the TCP idle connection. The value can be set between 4 and 30 minutes.
      domain_name_label       = "galtestdemo" #(Optional) Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system.
      reverse_fqdn            = null          #(Optional) A fully qualified domain name that resolves to this public IP address. If the reverseFqdn is specified, then a PTR DNS record is created pointing from the IP address in the in-addr.arpa domain to the reverse FQDN.
      zones                   = ["1"]         #(Optional) A collection containing the availability zone to allocate the Public IP in.
    }

    pip2 = {
      id     = "2"
      prefix = "sec"
    }
  }
}

variable "net_additional_tags" {
  default = {
    iac = "terraform"
  }
}

#Call module
module "Az-VirtualNetwork-Demo" {
  source = "git::https://github.com/JamesDLD/terraform-azurerm-Az-VirtualNetwork.git//?ref=master"
  #source = "../../"
  #source = "JamesDLD/Az-VirtualNetwork/azurerm"
  #version                     = "0.1.2"
  net_prefix                  = "product-perim"
  network_resource_group_name = "infr-jdld-noprd-rg1"
  virtual_networks            = var.virtual_networks
  subnets                     = var.subnets
  route_tables                = var.route_tables
  network_security_groups     = var.network_security_groups
  pips                        = var.pips
  vnets_to_peer               = var.vnets_to_peer
  net_additional_tags         = var.net_additional_tags
}
