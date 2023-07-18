variable "resourceName" {
  description = "The name of the Managed Cluster resource."
  type        = string
}

variable "location" {
  description = "The location of AKS resource."
  type        = string
}

variable "dnsPrefix" {
  description = "Optional DNS prefix to use with hosted Kubernetes API server FQDN."
  type        = string
  default     = "gitlab"
}

variable "osDiskSizeGB" {
  description = "Disk size (in GiB) to provision for each of the agent pool nodes."
  type        = number
  default     = 1023
}

variable "kubernetesVersion" {
  description = "The version of Kubernetes."
  type        = string
  default     = "1.25.6"
}

variable "additional_node_pools" {
  description = "Additional node pools to be created"
  type = list(object({
    name                  = string
    node_count            = number
    vm_size               = string
    os_disk_size_gb       = number
    type                  = string
    enable_auto_scaling   = bool
    min_count             = number
    max_count             = number
    enable_node_public_ip = bool
    zones                 = list(string)
    orchestrator_version  = string
  }))
  default = []
}

variable "fips_enabled" {
  description = "Boolean flag to turn on and off FIPS."
  type        = bool
  default     = true
}

variable "networkPlugin" {
  description = "Network plugin used for building Kubernetes network."
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.networkPlugin)
    error_message = "The value of networkPlugin must be either 'azure' or 'kubenet'."
  }
}

variable "sshPublicKey" {
  description = "SSH public key used for accessing the virtual machines."
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6QOFspIGBbt9Vug3OmfD4O5yNOWPlePmcAPWzUjYIJ5yiScQKz/WE1G2QLJ40bVhu3ytK/sqEToKuVwLw0xVAnkF+uxBBkEu00Gcq1NzjKkQjS9kVT/VVD4uNzg/uHltEAWqHXrsxHgjiOmNfbltlxYX3EncSmWSIR5PZN5/If/vdwGqhbnfx3DmYol4r+/bz+BmFnYzLgWZD3qqzmys8Y8h/wVzXFGDo24Z92ctLiEWCZnBDPCEBasEUsZpHMBefFabf6dEGI2qEuSw/To+3tX7QfpQiw4uJy27sIutqqw4LcYZ6fye0oMwgbobsqqqrykyUb8vdO2gR0MJCf54L example@example.com"
}

variable "enableRBAC" {
  description = "Boolean flag to turn on and off of RBAC."
  type        = bool
  default     = true
}

variable "vmssNodePool" {
  description = "Boolean flag to turn on and off of virtual machine scale sets."
  type        = bool
  default     = false
}

variable "windowsProfile" {
  description = "Boolean flag to turn on and off of virtual machine scale sets."
  type        = bool
  default     = false
}

variable "windowsPassword" {
  description = "Boolean flag to turn on and off of virtual machine scale sets."
  type        = string
  default     = "12qwaszx!@QWASZX"
}

variable "nodeResourceGroup" {
  description = "The name of the resource group containing agent pool nodes."
  type        = string
}

variable "upgradeChannel" {
  description = "Auto upgrade channel for a managed cluster."
  type        = string
  validation {
    condition     = contains(["none", "patch", "rapid", "stable", "node-image"], var.upgradeChannel)
    error_message = "The upgradeChannel value must be one of: none, patch, rapid, stable, node-image."
  }
}


variable "adminGroupObjectIDs" {
  description = "An array of AAD group object ids to give administrative access."
  type        = list(string)
  default     = []
}

variable "azureRbac" {
  description = "Enable or disable Azure RBAC."
  type        = bool
  default     = false
}

variable "disableLocalAccounts" {
  description = "Enable or disable local accounts."
  type        = bool
  default     = false
}

variable "enablePrivateCluster" {
  description = "Enable private network access to the Kubernetes cluster."
  type        = bool
  default     = true
}

variable "enableAzurePolicy" {
  description = "Boolean flag to turn on and off Azure Policy addon."
  type        = bool
  default     = true
}

variable "enableOmsAgent" {
  description = "Boolean flag to turn on and off omsagent addon."
  type        = bool
  default     = true
}

variable "workspaceRegion" {
  description = "Specify the region for your OMS workspace."
  type        = string
  default     = "East US"
}

variable "workspaceName" {
  description = "Specify the name of the OMS workspace."
  type        = string
}

variable "omsWorkspaceId" {
  description = "Specify the resource id of the OMS workspace."
  type        = string
}

variable "omsSku" {
  description = "Select the SKU for your workspace."
  type        = string
  default     = "standalone"
  validation {
    condition     = contains(["free", "standalone", "pernode"], var.omsSku)
    error_message = "The value of omsSku must be either 'free', 'standalone' or 'pernode'."
  }
}

variable "automatic_channel_upgrade" {
  description = "Boolean flag to turn on and off automatic channel upgrade."
  type        = string
  default     = "patch"
  validation {
    condition     = contains(["patch", "rapid", "node-image", "stable"], var.automatic_channel_upgrade)
    error_message = "The value of automatic upgrade must be either 'patch', 'rapid', 'node-image', or 'stable'."
  }
}

variable "http_application_routing_enabled" {
  description = "Boolean flag to turn on and off HTTP application routing."
  type        = bool
  default     = true
}

variable "acrName" {
  description = "Specify the name of the Azure Container Registry."
  type        = string
  default     = "AKSACR01"
}

variable "acrResourceGroup" {
  description = "The name of the resource group the container registry is associated with."
  type        = string
  default     = "ralphael"
}

variable "guidValue" {
  description = "The unique id used in the role assignment of the kubernetes service to the container registry service. It is recommended to use the default value."
  type        = string
  default     = "[newGuid()]"
}

variable "networkPolicy" {
  description = "Network policy used for building Kubernetes network."
  type        = string
  default     = "azure"
}

variable "enableAGW" {
  description = "Boolean flag to turn on and off Application Gateway addon."
  type        = bool
  default     = true
}

variable "linux_admin_username" {
  description = "The Linux administrator username."
  type        = string
  default     = "azureuser"
}

variable "node_resource_group_name" {
  description = "The name of the resource group containing agent pool nodes."
  type        = string
  default     = "ralphael2-AKS-Bits"
}

#variable "AGWsubnetID" {
#  description = "The ID of the subnet to use for the Application Gateway."
#  type        = string
#}