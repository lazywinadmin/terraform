#https://www.hashicorp.com/blog/kubernetes-cluster-with-aks-and-terraform/
provider "azurerm" {
    subscription_id = "${var.azure_subscription_id}"
    client_id = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
    tenant_id = "${var.azure_tenant_id}"
}

variable "resource_group_name" {
  default = "aksbasic2"
}

variable "location" {
  default = "West US"
}

variable "cluster_name" {
  default = "someclustername"
}

variable "dns_prefix" {
  default = "fx201911"
}

variable "ssh_public_key" {
  default = "id_rsa.pub"
}

variable "agent_count" {
  default = "2"
}

resource "azurerm_resource_group" "k8s" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.k8s.location}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  dns_prefix          = "${var.dns_prefix}"

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "${file("${var.ssh_public_key}")}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.k8s_client_id}"
    client_secret = "${var.k8s_client_secret}"
  }
}