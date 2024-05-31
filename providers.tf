provider "azurerm" {
    features {}
}

terraform {
    required_providers {
        azuread = {
            source = "hashicorp/azuread"
            version = ">= 2.35.0"
        }
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 3.45.0"
        }
    }

    backend "azurerm" {
        resource_group_name = "rg-procap360-global"
        storage_account_name = "procap360tfstate"
        container_name = "terraform-states"
        key = "procap360adr-poc.tfstate"
    }
}
