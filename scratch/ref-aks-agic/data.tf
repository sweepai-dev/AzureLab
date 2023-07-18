
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "/Users/johnsonrad/Documents/Code/Lab/scratch/VanillaLab/terraform.tfstate"
  }
}

data "azurerm_container_registry" "acr" {
  name                = var.acrName
  resource_group_name = var.acrResourceGroup
}
