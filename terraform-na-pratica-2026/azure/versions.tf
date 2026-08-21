terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.1"
    }
  }
}

provider "azurerm" {
  features {}

  # A partir da v4 do provider, subscription_id e obrigatorio.
  # Pegue o valor com: az account show --query id -o tsv
  subscription_id = var.subscription_id
}
