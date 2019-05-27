# Terraform

terraform tests

## Basics

### Terraform Components

* Terraform is an executable
* Terraform file (s)
* Terraform state file
* Terraform backup file
* Terraform lock file

### Terraform template parts

* variable (used to store information)
* provider (ex: AWS, Azure,...)
* resource (ex: VM)
* output   (value to output for this template)

## Automate infrastructure deployment

1. Provisioning Resources
1. Planning Updates
1. Using Source Control
1. Reusing templates

## Requirements

### Authentication

Before running any terraform command, you will need to take care of the authentification that terraform will leverage.

For example, in the case of Azure, you will need to follow this: #  https://www.terraform.io/docs/providers/azurerm/index.html

## Other Resources

* [Terraform.io](Terraform.io)
* Terraform on azure
  * Microsoft documentation: [http://aka.ms/tfhub](http://aka.ms/tfhub)
