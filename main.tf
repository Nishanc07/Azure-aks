resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-rg"
  location = "northeurope"
  
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  address_space       = ["10.38.0.0/16"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  depends_on = [azurerm_resource_group.aks_rg]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.38.0.0/22"]
  depends_on           = [azurerm_virtual_network.aks_vnet] 
}

resource "tls_private_key" "vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.vm.private_key_pem
  filename        = pathexpand("~/.ssh/azure_vm_key")
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.vm.public_key_openssh
  filename        = pathexpand("~/.ssh/azure_vm_key.pub")
  file_permission = "0644"
}

data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.aks_rg.location
  include_preview = false  
}
 

resource "azurerm_kubernetes_cluster" "azure_aks" {
  name                = "azure-aks"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "xyz"
  kubernetes_version    =  data.azurerm_kubernetes_service_versions.current.latest_version

  default_node_pool {
  name                = "nodepool"
  vm_size             = "standard_b2ms"  
  vnet_subnet_id      = azurerm_subnet.aks_subnet.id
  os_disk_size_gb     = 30
  type                = "VirtualMachineScaleSets"

  enable_auto_scaling = true
  min_count           = 2
  max_count           = 3

  

  node_labels = {
    "nodepool-type" = "system"
    "environment"   = "prod"
    "nodepoolos"    = "linux"
  }
}
   
  

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = tls_private_key.vm.public_key_openssh
    }
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
  }

  tags = {
    Environment = "xyzaks"
  }

  depends_on = [
    tls_private_key.vm,
    azurerm_virtual_network.aks_vnet,
    azurerm_subnet.aks_subnet
  ] 
}
