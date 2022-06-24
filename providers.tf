terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  #alias           = "msys_azure"
  #subscription_id = "af5a6fb3-b792-4f0e-aa58-7cf18b9cad30"
  features {}
}