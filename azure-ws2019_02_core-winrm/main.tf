
provider "azurerm" {
    subscription_id = "${var.azure_subscription_id}"
    client_id = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
    tenant_id = "${var.azure_tenant_id}"
}

variable "prefix" {
  default = "fx"
}

variable "adminuser" {
  default = "fxadmin"
}

variable "adminpassw" {
  default = "Passw0rd1234__"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "West US"
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
    public_ip_address_id         = "${azurerm_public_ip.example.id}"
  }
}

# resource "azurerm_storage_account" "test" {
#   name                      = "helloworld94404"
#   resource_group_name       = "${azurerm_resource_group.main.name}"
#   location                  = "${azurerm_resource_group.main.location}"
#   account_tier              = "Standard"
#   account_replication_type  = "GRS"
# }

# resource "azurerm_storage_container" "test" {
#   name                  = "helloworld"
#   storage_account_name  = "${azurerm_storage_account.test.name}"
#   container_access_type = "private"
# }

resource "azurerm_public_ip" "example" {
  name                = "${var.prefix}-publicip"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  allocation_method   = "Static"
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_E16s_v3" #"Standard_A0"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-Core" # "2016-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    #vhd_uri           = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/myosdisk1.vhd"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"

  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "${var.adminuser}"
    admin_password = "${var.adminpassw}"
  }

  # OS customization
  os_profile_windows_config {
    enable_automatic_upgrades = false
    provision_vm_agent = true
    winrm {
      protocol = "http"
    }
  }

  provisioner "remote-exec" {
    connection {
      host = "${azurerm_public_ip.example.ip_address}"
      type = "winrm"
      port = 5985
      https = false
      timeout = "5m"
      user = "${var.adminuser}"
      password = "${var.adminpassw}"
      insecure = "true"
      use_ntlm = "true"
    }
    inline = [
      "powershell.exe -ExecutionPolicy Unrestricted -Command {Install-WindowsFeature -name Web-Server -IncludeManagementTools}",
    ]
  }
}

output "pip" {
  value = ["${azurerm_public_ip.example.ip_address}"]
}