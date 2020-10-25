provider "azurerm" {
    subscription_id = "${var.azure_subscription_id}"
    client_id = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
    tenant_id = "${var.azure_tenant_id}"
}

variable "prefix" {
  default = "fx"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "West US 2"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

# module "ad-create" {
#   source  = "ghostinthewires/ad-create/azurerm"
#   version = "1.0.0"
#   # insert the 7 required variables here
#   admin_username = "fxadmin"
#   admin_password = "P@ssw0rd!!!"
#   location = "westus2"
#   prefix = "fxlab"
#   private_ip_address = ""
#   resource_group_name = azurerm_resource_group.adsipstest1.name
#   subnet_id = ""
# }

# admin_password
# Description: The password associated with the local administrator account on the virtual machine
# admin_username
# Description: The username associated with the local administrator account on the virtual machine
# location
# Description: The Azure Region in which the Resource Group exists
# prefix
# Description: The prefix used for all resources in this example. Needs to be a short (6 characters) alphanumeric string. Example: `myprefix`.
# private_ip_address
# Description: The private IP address for the Domain Controller's NIC
# resource_group_name
# Description: The name of the Resource Group where the Domain Controllers resources will be created
# subnet_id
# Description: The Subnet ID which the Domain Controller's NIC should be created in. This should be have already been created seperately

