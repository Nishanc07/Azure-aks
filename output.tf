output "kube_config" {
  value     = azurerm_kubernetes_cluster.azure_aks.kube_config_raw
  sensitive = true
  description = "Raw kubeconfig to access the AKS cluster"
}

output "cluster_id" {
  value       = azurerm_kubernetes_cluster.azure_aks.id
  description = "AKS Cluster Resource ID"
}

output "cluster_name" {
  value       = azurerm_kubernetes_cluster.azure_aks.name
  description = "AKS Cluster Name"
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.azure_aks.node_resource_group
  description = "Azure-managed Node Resource Group"
}

output "vnet_id" {
  value       = azurerm_virtual_network.aks_vnet.id
  description = "Virtual Network ID"
}

output "subnet_id" {
  value       = azurerm_subnet.aks_subnet.id
  description = "Subnet ID used by the AKS node pool"
}

output "ssh_public_key" {
  value       = tls_private_key.vm.public_key_openssh
  description = "Public key used for SSH access to the node VMs"
}



