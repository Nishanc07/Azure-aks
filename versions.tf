terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.76"  # Or latest stable
    }
  }
  required_version = ">= 1.4.0"
}

provider "azurerm" {
  # Configuration options
  features {
    
  }
  subscription_id = "a584d13d-2dd5-4bbf-85ff-b0c51f60baca"
  
}
