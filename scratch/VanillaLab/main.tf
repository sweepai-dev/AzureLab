#Need to create subnet for ingress controller inside of existing vnet

provider "azurerm" {
  features {}
  #environment                = "usgovernment"
  skip_provider_registration = true
}

# get sub for later use
data "azurerm_subscription" "current" {}


resource "azurerm_resource_group" "example" {
  name     = "ralphael2"
  location = "eastus"
}

# Create the hub virtual network
resource "azurerm_virtual_network" "hub" {
  name                = "hubNetwork"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.2.0.0/16"]
}

# Create the hub subnet
resource "azurerm_subnet" "hub" {
  name                                          = "hubSubnet"
  resource_group_name                           = azurerm_resource_group.example.name
  virtual_network_name                          = azurerm_virtual_network.hub.name
  address_prefixes                              = ["10.2.0.0/24"]
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}

# Create the spoke1 and spoke2 virtual networks and subnets
resource "azurerm_virtual_network" "spoke1" {
  name                = "spoke1Network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.3.0.0/16"]
}

resource "azurerm_subnet" "spoke1" {
  name                                          = "spoke1Subnet"
  resource_group_name                           = azurerm_resource_group.example.name
  virtual_network_name                          = azurerm_virtual_network.spoke1.name
  address_prefixes                              = ["10.3.0.0/24"]
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}

resource "azurerm_virtual_network" "spoke2" {
  name                = "spoke2Network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.4.0.0/16"]
}

resource "azurerm_subnet" "spoke2" {
  name                                          = "spoke2Subnet"
  resource_group_name                           = azurerm_resource_group.example.name
  virtual_network_name                          = azurerm_virtual_network.spoke2.name
  address_prefixes                              = ["10.4.0.0/24"]
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}

#Create Tier-2 Vnet and subnet
resource "azurerm_virtual_network" "tier2" {
  name                = "tier2Network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.128/26"]
}

resource "azurerm_subnet" "tier2-GWsubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.tier2.name
  address_prefixes     = ["10.0.0.128/27"]
}

resource "azurerm_subnet" "tier2-ergsubnet" {
  name                 = "Tier2EGRSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.tier2.name
  address_prefixes     = ["10.0.0.160/27"]
}

# Link the private DNS zone to the hub virtual network
#resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
#  name                  = "hubLink"
#  resource_group_name   = azurerm_resource_group.example.name
#  private_dns_zone_name = azurerm_private_dns_zone.example.name
#  virtual_network_id    = azurerm_virtual_network.hub.id
#}

# Link the private DNS zone to the spoke virtual networks
#resource "azurerm_private_dns_zone_virtual_network_link" "spoke1" {
#  name                  = "spoke1Link"
#  resource_group_name   = azurerm_resource_group.example.name
#  private_dns_zone_name = azurerm_private_dns_zone.example.name
#  virtual_network_id    = azurerm_virtual_network.spoke1.id
#}

#resource "azurerm_private_dns_zone_virtual_network_link" "spoke2" {
#  name                  = "spoke2Link"
#  resource_group_name   = azurerm_resource_group.example.name
#  private_dns_zone_name = azurerm_private_dns_zone.example.name
#  virtual_network_id    = azurerm_virtual_network.spoke2.id
#}

# Create a storage account
resource "azurerm_storage_account" "example" {
  name                     = "example234storage7897"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# Create a private endpoint for the storage account
resource "azurerm_private_endpoint" "example" {
  name                = "examplePrivateEndpoint"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.hub.id

  private_service_connection {
    name                           = "examplePrivateServiceConnection"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_public_ip" "hub-pip" {
  name                = "examplePublicIP"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Dynamic"
}


# Hub Nic
resource "azurerm_network_interface" "hub-nic" {
  name                = "hub-vm-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.hub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hub-pip.id
  }
}

# Create Hub windows 2016 Virtual Machine
resource "azurerm_windows_virtual_machine" "ralphael2-hub-vm" {
  name                     = "hub-vm"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  size                     = "Standard_DS1_v2"
  admin_username           = "azureuser"
  admin_password           = "12qwaszx!@QWASZX"
  network_interface_ids    = [azurerm_network_interface.hub-nic.id]
  computer_name            = "hub-vm"
  enable_automatic_updates = true
  provision_vm_agent       = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = "HUB-VM"
  }
}

#spoke Network public IP
resource "azurerm_public_ip" "spoke1" {
  name                = "spoke1PublicIP"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

# Spoke Nic
resource "azurerm_network_interface" "spoke1-nic" {
  name                = "spoke1-vm-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.spoke1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.spoke1.id
  }
}

# Create Spoke windows 2016 Virtual Machine
resource "azurerm_windows_virtual_machine" "ralphael2-spoke1-vm" {
  name                     = "spoke1-vm"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  size                     = "Standard_DS1_v2"
  admin_username           = "azureuser"
  admin_password           = "12qwaszx!@QWASZX"
  network_interface_ids    = [azurerm_network_interface.spoke1-nic.id]
  computer_name            = "spoke1-vm"
  enable_automatic_updates = true
  provision_vm_agent       = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = "SPOKE1-VM"
  }
}


### PEERING #####
resource "azurerm_virtual_network_peering" "spoke1_to_tier2" {
  name                      = "spoke1-to-tier2"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.tier2.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "spoke2_to_tier2" {
  name                      = "spoke2-to-tier2"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id = azurerm_virtual_network.tier2.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "tier2_to_spoke1" {
  name                      = "tier2-to-spoke1"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.tier2.name
  remote_virtual_network_id = azurerm_virtual_network.spoke1.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "tier2_to_spoke2" {
  name                      = "tier2-to-spoke2"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.tier2.name
  remote_virtual_network_id = azurerm_virtual_network.spoke2.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "hub_to_tier2" {
  name                      = "hub-to-tier2"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.tier2.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "tier2_to_hub" {
  name                      = "tier2-to-hub"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.tier2.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

#Create Spoke2 VM
resource "azurerm_public_ip" "spoke2" {
  name                = "spoke2PublicIP"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

# Spoke2 Nic
resource "azurerm_network_interface" "spoke2-nic" {
  name                = "spoke2-vm-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.spoke2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.spoke2.id
  }
}

# Create Spoke2 windows 2016 Virtual Machine
resource "azurerm_windows_virtual_machine" "ralphael2-spoke2-vm" {
  name                     = "spoke2-vm"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  size                     = "Standard_DS1_v2"
  admin_username           = "azureuser"
  admin_password           = "12qwaszx!@QWASZX"
  network_interface_ids    = [azurerm_network_interface.spoke2-nic.id]
  computer_name            = "spoke2-vm"
  enable_automatic_updates = true
  provision_vm_agent       = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = "SPOKE2-VM"
  }
}

## Create DNS record for hub vm private IP
#resource "azurerm_private_dns_a_record" "hub-vm" {
#  name                = "hub-vm"
#  zone_name           = azurerm_private_dns_zone.example.name
#  resource_group_name = azurerm_resource_group.example.name
#  ttl                 = 300
#  records             = [azurerm_windows_virtual_machine.ralphael2-hub-vm.private_ip_address]
#}

# Create DNS record for spoke1 vm private IP
#resource "azurerm_private_dns_a_record" "spoke1-vm" {
#  name                = "spoke1-vm"
#  zone_name           = azurerm_private_dns_zone.example.name
#  resource_group_name = azurerm_resource_group.example.name
#  ttl                 = 300
#  records             = [azurerm_windows_virtual_machine.ralphael2-spoke1-vm.private_ip_address]
#}

# Create DNS record for spoke2 vm private IP
#resource "azurerm_private_dns_a_record" "spoke2-vm" {
#  name                = "spoke2-vm"
#  zone_name           = azurerm_private_dns_zone.example.name
#  resource_group_name = azurerm_resource_group.example.name
#  ttl                 = 300
#  records             = [azurerm_windows_virtual_machine.ralphael2-spoke2-vm.private_ip_address]
#}

# Create DNS record for the storage account private endpoint
#resource "azurerm_private_dns_a_record" "storage" {
#  name                = "storage"
#  zone_name           = azurerm_private_dns_zone.example.name
#  resource_group_name = azurerm_resource_group.example.name
#  ttl                 = 300
#  records             = [azurerm_private_endpoint.example.private_service_connection.0.private_ip_address]
#}


# For the hub VM
resource "azurerm_virtual_machine_extension" "hub" {
  name                 = "hubFirewallRule"
  virtual_machine_id   = azurerm_windows_virtual_machine.ralphael2-hub-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe New-NetFirewallRule –DisplayName 'Allow ICMPv4-In' –Protocol ICMPv4"
    }
SETTINGS
}

# For the spoke VM
resource "azurerm_virtual_machine_extension" "spoke1" {
  name                 = "spokeFirewallRule"
  virtual_machine_id   = azurerm_windows_virtual_machine.ralphael2-spoke1-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe New-NetFirewallRule –DisplayName 'Allow ICMPv4-In' –Protocol ICMPv4"
    }
SETTINGS
}

# Create Newtwork Security Group for Hub VM to only allow RDP
resource "azurerm_network_security_group" "hub" {
  name                = "hub-vm-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create Newtwork Security Group for Spoke VM to only allow RDP
resource "azurerm_network_security_group" "spoke" {
  name                = "spoke-vm-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG to Hub VM
resource "azurerm_network_interface_security_group_association" "hub" {
  network_interface_id      = azurerm_network_interface.hub-nic.id
  network_security_group_id = azurerm_network_security_group.hub.id
}

# Associate NSG to Spoke1 VM
resource "azurerm_network_interface_security_group_association" "spoke1" {
  network_interface_id      = azurerm_network_interface.spoke1-nic.id
  network_security_group_id = azurerm_network_security_group.spoke.id
}

# Associate NSG to Spoke2 VM
resource "azurerm_network_interface_security_group_association" "spoke2" {
  network_interface_id      = azurerm_network_interface.spoke2-nic.id
  network_security_group_id = azurerm_network_security_group.spoke.id
}
/*
# Deny connectivity inbound spoke vnet
resource "azurerm_network_security_rule" "spoke-to-hub" {
  name                        = "ADMIN-DENY-INBOUND"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.spoke.name
}

# Deny connectivity outbound spoke vnet
resource "azurerm_network_security_rule" "hub-to-spoke" {
  name                        = "ADMIN-DENY-OUTBOUND"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.spoke.name
}

#  user-assigned managed identity with contrib rights
resource "azurerm_user_assigned_identity" "testUMI" {
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  name                = "testUMI"
}

# Create a contributor role assignment for the user-assigned managed identity over the subscription
resource "azurerm_role_assignment" "testUMI" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.testUMI.principal_id
}
*/