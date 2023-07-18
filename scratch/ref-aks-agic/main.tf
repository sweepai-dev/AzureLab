#resource "azurerm_resource_group" "example" {
#  name     = "ralphael2"
#  location = "USGov Virginia"
#}

resource "azurerm_subnet" "appgw" {
  name                 = "appgwSubnet"
  resource_group_name  = data.terraform_remote_state.network.outputs.resource_group_name
  virtual_network_name = data.terraform_remote_state.network.outputs.spoke1_vnet_name
  address_prefixes     = ["10.3.1.0/24"]
}

resource "azurerm_public_ip" "appgw-pip" {
  name                = "appgwPublicIP"
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  location            = data.terraform_remote_state.network.outputs.resource_group_location
  allocation_method   = "Static"
  sku                 = "Standard"
}


#Application Gateway
resource "azurerm_application_gateway" "agic" {
  name                = "agic"
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  location            = data.terraform_remote_state.network.outputs.resource_group_location
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "agic-ip"
    subnet_id = azurerm_subnet.appgw.id
  }
  frontend_port {
    name = "http"
    port = 80
  }
  frontend_port {
    name = "https"
    port = 443
  }
  frontend_ip_configuration {
    name                 = "agic-ip-configuration"
    public_ip_address_id = azurerm_public_ip.appgw-pip.id
  }
  backend_address_pool {
    name = "backend-pool"
    fqdns = [
      #data.terraform_remote_state.network.outputs.ralphael2-hub-vm_private_ip_address,
      #data.terraform_remote_state.network.outputs.ralphael2-spoke-vm_private_ip_address
      #azurerm_windows_virtual_machine.ralphael2-hub-vm.private_ip_address,
      #azurerm_windows_virtual_machine.ralphael2-spoke-vm.private_ip_address
    ]
  }
  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "agic-ip-configuration"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }
  #http_listener {
  #  name                           = "https-listener"
  #  frontend_ip_configuration_name = "agic-ip-configuration"
  #  frontend_port_name             = "https"
  #  protocol                       = "Https"
  #  ssl_certificate_name           = "agic-cert"
  #}
  #ssl_certificate {
  # name     = "agic-cert"
  #data     = filebase64(var.sslCertificate)
  #password = var.sslCertificatePassword
  #}
  request_routing_rule {
    name                       = "http-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 100
  }
  #request_routing_rule {
  #  name                       = "https-rule"
  #  rule_type                  = "Basic"
  #  http_listener_name         = "https-listener"
  #  backend_address_pool_name  = "backend-pool"
  #  backend_http_settings_name = "http-settings"

  #}
}



# deploy hardended AKS private cluster that uses azure CNI and private DNS
resource "azurerm_kubernetes_cluster" "example" {
  name                      = var.resourceName
  resource_group_name       = data.terraform_remote_state.network.outputs.resource_group_name
  location                  = data.terraform_remote_state.network.outputs.resource_group_location
  private_cluster_enabled   = var.enablePrivateCluster
  dns_prefix                = var.dnsPrefix
  kubernetes_version        = var.kubernetesVersion
  automatic_channel_upgrade = var.automatic_channel_upgrade
  azure_policy_enabled      = var.enableRBAC
  node_resource_group       = var.node_resource_group_name
  #http_application_routing_enabled = var.http_application_routing_enabled------can be configured via the portal but not throubh terraform currently.

  linux_profile {
    admin_username = var.windowsProfile
    ssh_key {
      key_data = var.sshPublicKey
    }
  }

  oms_agent {
    log_analytics_workspace_id = "/subscriptions/46c1bdab-b54a-49ba-a449-36af32ddee1c/resourceGroups/ralphael/providers/Microsoft.OperationalInsights/workspaces/mainloganalytics-law"
  }

  identity {
    type = "SystemAssigned"
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.agic.id
  }


  network_profile {
    network_plugin     = var.networkPlugin
    network_policy     = var.networkPolicy
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    outbound_type      = "loadBalancer"
    load_balancer_sku  = "standard"

  }

  default_node_pool {
    name                  = "agentpool"
    vm_size               = "Standard_D4s_v3"
    os_disk_size_gb       = var.osDiskSizeGB
    type                  = "VirtualMachineScaleSets"
    enable_auto_scaling   = true
    min_count             = 1
    max_count             = 5
    enable_node_public_ip = false
    zones                 = ["1", "2", "3"]
    orchestrator_version  = var.kubernetesVersion
    fips_enabled          = var.fips_enabled
    vnet_subnet_id        = data.terraform_remote_state.network.outputs.spoke1_subnet_id
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "example" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
  vm_size               = "Standard_D4s_v3"
  orchestrator_version  = var.kubernetesVersion
  enable_auto_scaling   = true
  min_count             = 0
  max_count             = 5
  os_disk_size_gb       = var.osDiskSizeGB
  zones                 = ["1", "2", "3"]
  enable_node_public_ip = false
  depends_on            = [azurerm_kubernetes_cluster.example]
  mode                  = "User"
  vnet_subnet_id        = data.terraform_remote_state.network.outputs.spoke1_subnet_id

}



resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = "hub-vnet-to-private-dns-zone-link"
  resource_group_name   = data.terraform_remote_state.network.outputs.resource_group_name
  private_dns_zone_name = "aks-private-dns-zone"
  virtual_network_id    = data.terraform_remote_state.network.outputs.hub_vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke1" {
  name                  = "spoke1-vnet-to-private-dns-zone-link"
  resource_group_name   = data.terraform_remote_state.network.outputs.resource_group_name
  private_dns_zone_name = "aks-private-dns-zone"
  virtual_network_id    = data.terraform_remote_state.network.outputs.spoke1_vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke2" {
  name                  = "spoke2-vnet-to-private-dns-zone-link"
  resource_group_name   = data.terraform_remote_state.network.outputs.resource_group_name
  private_dns_zone_name = "aks-private-dns-zone"
  virtual_network_id    = data.terraform_remote_state.network.outputs.spoke2_vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone" "example" {
  name                = "aks-private-dns-zone"
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
}

resource "azurerm_private_endpoint" "example" {
  name                = "aks-private-endpoint"
  location            = data.terraform_remote_state.network.outputs.resource_group_location
  resource_group_name = data.terraform_remote_state.network.outputs.resource_group_name
  subnet_id           = data.terraform_remote_state.network.outputs.spoke1_subnet_id

  private_service_connection {
    name                           = "aks-private-endpoint-connection"
    private_connection_resource_id = azurerm_kubernetes_cluster.example.id
    subresource_names              = ["kubeApi"]
    is_manual_connection           = false
  }
}

#resource "azurerm_private_dns_a_record" "example" {
#  name                = "aks-private-endpoint"
#  zone_name           = azurerm_private_dns_zone.example.name
#  resource_group_name = azurerm_private_dns_zone.example.resource_group_name
#  ttl                 = 300
#  records             = [azurerm_private_endpoint.example.private_ip_address[0]]
#}