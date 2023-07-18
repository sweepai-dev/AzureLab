output "resource_group_name" {
  value = azurerm_resource_group.example.name
}

output "resource_group_location" {
  value = azurerm_resource_group.example.location
}

output "resource_group_id" {
  value = azurerm_resource_group.example.id
}

output "hub_vnet_name" {
  value = azurerm_virtual_network.hub.name
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "hub_subnet_name" {
  value = azurerm_subnet.hub.name
}

output "hub_subnet_id" {
  value = azurerm_subnet.hub.id
}

output "spoke1_vnet_name" {
  value = azurerm_virtual_network.spoke1.name
}

output "spoke1_vnet_id" {
  value = azurerm_virtual_network.spoke1.id
}

output "spoke1_subnet_name" {
  value = azurerm_subnet.spoke1.name
}

output "spoke1_subnet_id" {
  value = azurerm_subnet.spoke1.id
}

output "spoke2_vnet_name" {
  value = azurerm_virtual_network.spoke2.name
}

output "spoke2_vnet_id" {
  value = azurerm_virtual_network.spoke2.id
}

output "spoke2_subnet_name" {
  value = azurerm_subnet.spoke2.name
}

output "spoke2_subnet_id" {
  value = azurerm_subnet.spoke2.id
}

output "storage_account_name" {
  value = azurerm_storage_account.example.name
}

output "storage_account_id" {
  value = azurerm_storage_account.example.id
}

output "private_endpoint_name" {
  value = azurerm_private_endpoint.example.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.example.id
}

output "hub_public_ip_name" {
  value = azurerm_public_ip.hub-pip.name
}

output "hub_public_ip_id" {
  value = azurerm_public_ip.hub-pip.id
}

output "hub_nic_name" {
  value = azurerm_network_interface.hub-nic.name
}

output "hub_nic_id" {
  value = azurerm_network_interface.hub-nic.id
}

output "hub_vm_name" {
  value = azurerm_windows_virtual_machine.ralphael2-hub-vm.name
}

output "hub_vm_id" {
  value = azurerm_windows_virtual_machine.ralphael2-hub-vm.id
}

output "spoke1_public_ip_name" {
  value = azurerm_public_ip.spoke1.name
}

output "spoke1_public_ip_id" {
  value = azurerm_public_ip.spoke1.id
}

output "spoke1_nic_name" {
  value = azurerm_network_interface.spoke1-nic.name
}

output "spoke1_nic_id" {
  value = azurerm_network_interface.spoke1-nic.id
}

output "spoke1_vm_name" {
  value = azurerm_windows_virtual_machine.ralphael2-spoke1-vm.name
}

output "spoke1_vm_id" {
  value = azurerm_windows_virtual_machine.ralphael2-spoke1-vm.id
}

output "spoke1_to_tier2_peering_name" {
  value = azurerm_virtual_network_peering.spoke1_to_tier2.name
}

output "spoke1_to_tier2_peering_id" {
  value = azurerm_virtual_network_peering.spoke1_to_tier2.id
}

output "spoke2_public_ip_name" {
  value = azurerm_public_ip.spoke2.name
}

output "spoke2_public_ip_id" {
  value = azurerm_public_ip.spoke2.id
}

output "spoke2_nic_name" {
  value = azurerm_network_interface.spoke2-nic.name
}

output "spoke2_nic_id" {
  value = azurerm_network_interface.spoke2-nic.id
}

output "spoke2_vm_name" {
  value = azurerm_windows_virtual_machine.ralphael2-spoke2-vm.name
}

output "spoke2_vm_id" {
  value = azurerm_windows_virtual_machine.ralphael2-spoke2-vm.id
}

output "spoke2_to_tier2_peering_name" {
  value = azurerm_virtual_network_peering.spoke2_to_tier2.name
}

output "spoke2_to_tier2_peering_id" {
  value = azurerm_virtual_network_peering.spoke2_to_tier2.id
}

output "hub_nsg_name" {
  value = azurerm_network_security_group.hub.name
}

output "hub_nsg_id" {
  value = azurerm_network_security_group.hub.id
}

output "spoke_nsg_name" {
  value = azurerm_network_security_group.spoke.name
}

output "spoke_nsg_id" {
  value = azurerm_network_security_group.spoke.id
}

output "hub_nsg_association_id" {
  value = azurerm_network_interface_security_group_association.hub.id
}

output "spoke1_nsg_association_id" {
  value = azurerm_network_interface_security_group_association.spoke1.id
}

output "spoke2_nsg_association_id" {
  value = azurerm_network_interface_security_group_association.spoke2.id
}

output "ralphael2-hub-vm_private_ip_address" {
  value = azurerm_windows_virtual_machine.ralphael2-hub-vm.private_ip_address
}

output "ralphael2-spoke1-vm_private_ip_address" {
  value = azurerm_windows_virtual_machine.ralphael2-spoke1-vm.private_ip_address
}

output "ralphael2-spoke2-vm_private_ip_address" {
  value = azurerm_windows_virtual_machine.ralphael2-spoke2-vm.private_ip_address
}