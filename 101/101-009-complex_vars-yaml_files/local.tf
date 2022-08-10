locals {
  p = yamldecode(file("${path.root}/config.yaml")) # this converts all the queues into a list of maps
  v = flatten(
        [
            for name, vnet_links in local.p.privatednszones : [
                for linkname, linkid in vnet_links.vnet_links : {
                    private_dns_zone_name = vnet_links.name
                    vnet_link_name = linkname
                    vnet_link_id = linkid
                }
            ]
        ]
    )
}

# local.p
# {
#   "privatednszones" = [
#     {
#       "name" = "privatelink.mongo.cosmos.azure.com"
#       "vnet_links" = {
#         "hub1" = "/subscriptions/<sub_id>/resourceGroups/privatednszone/providers/Microsoft.Network/virtualNetworks/privatednszone-vnet"
#         "hub2" = "/subscriptions/<sub_id>/resourceGroups/privatednszone/providers/Microsoft.Network/virtualNetworks/privatednszone2-vnet"
#       }
#     },
#     {
#       "name" = "privatelink.documents.azure.com"
#       "vnet_links" = {
#         "hub1" = "/subscriptions/<sub_id>/resourceGroups/privatednszone/providers/Microsoft.Network/virtualNetworks/privatednszone-vnet"
#         "hub2" = "/subscriptions/<sub_id>/resourceGroups/privatednszone/providers/Microsoft.Network/virtualNetworks/privatednszone2-vnet"
#       }
#     },
#   ]
# }


# # local.v
# [
#   {
#     "private_dns_zone_name" = "privatelink.mongo.cosmos.azure.com"
#     "vnet_link_id" = "/subscriptions/<sub_id>/resourceGroups/privatednszone/providers/Microsoft.Network/virtualNetworks/privatednszone-vnet"
#     "vnet_link_name" = "hub1"
#   },
#   {
#     "private_dns_zone_name" = "privatelink.mongo.cosmos.azure.com"
#     "vnet_link_id" = "/subscriptions/<sub_id>/resourceGroups/privatednszone/providers/Microsoft.Network/virtualNetworks/privatednszone2-vnet"
#     "vnet_link_name" = "hub2"
#   },
#   {
#     "private_dns_zone_name" = "privatelink.documents.azure.com"
#     "vnet_link_id" = "/subscriptions/<sub_id>/resourceGroups/privatednszone/providers/Microsoft.Network/virtualNetworks/privatednszone-vnet"
#     "vnet_link_name" = "hub1"
#   },
#   {
#     "private_dns_zone_name" = "privatelink.documents.azure.com"
#     "vnet_link_id" = "/subscriptions/<sub_id>/resourceGroups/privatednszone/providers/Microsoft.Network/virtualNetworks/privatednszone2-vnet"
#     "vnet_link_name" = "hub2"
#   },
# ]
