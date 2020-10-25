module "mynetwork" {
    source = "../.."
    net_additional_tags = {
        iac = "terraform"
    }
    net_prefix = "fxtest"
    network_resource_group_name = "tfnetwork"
    virtual_networks = {
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
    vnets_to_peer = {
        vnets_to_peer1 = {
            vnet_key            = "vnet1"                   #(Mandatory)
            remote_vnet_name    = "fxtest-npd-vnet2" #(Mandatory)
            remote_vnet_rg_name = "tfnetwork" #"infr-jdld-noprd-rg1"     #(Mandatory)
        }
        vnets_to_peer2 = {
            vnet_key            = "vnet2"                   #(Mandatory)
            remote_vnet_name    = "fxtest-npd-vnet1" #(Mandatory)
            remote_vnet_rg_name = "tfnetwork" #"infr-jdld-noprd-rg1"     #(Mandatory)
            #remote_subscription_id = "43c91cd1-0bbf-40c0-9c3a-401b8dfd2dd3" #(Optional) use the current subscription if not provided
            #allow_virtual_network_access = ""                                     #(Optional) Controls if the VMs in the remote virtual network can access VMs in the local virtual network. Defaults to false.
            #allow_forwarded_traffic      = ""                                     #(Optional) Controls if forwarded traffic from VMs in the remote virtual network is allowed. Defaults to false.
            #allow_gateway_transit        = ""                                     #(Optional) Controls gatewayLinks can be used in the remote virtual network’s link to the local virtual network.
            #use_remote_gateways          = ""                                     #(Optional) Controls if remote gateways can be used on the local virtual network. If the flag is set to true, and allow_gateway_transit on the remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway. Defaults to false.
        }
    }
    subnets = {
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
    route_tables = {
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
