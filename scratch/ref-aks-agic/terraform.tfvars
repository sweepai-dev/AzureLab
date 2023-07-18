# FROM ARM PARAMETERS FILE
resourceName         = "AKS-Cluster-01"
location             = "usgovvirginia"
dnsPrefix            = "AKS-Cluster-01-dns"
kubernetesVersion    = "1.25.6"
networkPlugin        = "azure"
networkPolicy        = "azure"
enableRBAC           = true
nodeResourceGroup    = "MC_Ralphael_AKS-Cluster-01_usgovvirginia"
upgradeChannel       = "patch"
adminGroupObjectIDs  = ["0abb1e05-30c2-416b-ad99-b9537880643f"]
disableLocalAccounts = true
azureRbac            = true
enablePrivateCluster = true
enableAzurePolicy    = true
vmssNodePool         = true
workspaceName        = "MainLogAnalytics-LAW"
omsWorkspaceId       = "/subscriptions/46c1bdab-b54a-49ba-a449-36af32ddee1c/resourceGroups/ralphael/providers/Microsoft.OperationalInsights/workspaces/mainloganalytics-law"
workspaceRegion      = "usgovvirginia"
acrName              = "AKSACR01"
acrResourceGroup     = "Ralphael"
osDiskSizeGB         = 30
#AGWsubnetID          = "/subscriptions/46c1bdab-b54a-49ba-a449-36af32ddee1c/resourceGroups/Ralphael/providers/Microsoft.Network/virtualNetworks/Ralphael-VNET/subnets/AGW-Subnet"
additional_node_pools = [
  {
    name                  = "agentpool"
    node_count            = 3
    vm_size               = "Standard_D2s_v3"
    os_disk_size_gb       = 30
    type                  = "VirtualMachineScaleSets"
    enable_auto_scaling   = true
    min_count             = 1
    max_count             = 5
    enable_node_public_ip = false
    zones                 = ["1", "2", "3"]
    orchestrator_version  = "1.25.6"
    fips_enabled          = true
  },
  {
    name                  = "userpool"
    node_count            = 2
    vm_size               = "Standard_D4s_v3"
    os_disk_size_gb       = 50
    type                  = "VirtualMachineScaleSets"
    enable_auto_scaling   = false
    min_count             = 1
    max_count             = 3
    enable_node_public_ip = true
    zones                 = ["1", "2", "3"]
    orchestrator_version  = "1.25.6"
    fips_enabled          = true
  }
]
