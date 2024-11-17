terraform {
  backend "azurerm" {
    resource_group_name   = "keycloak-backend-rg"
    storage_account_name  = "keycloakstrg"
    container_name        = "keycloakcont"
    key                   = "terraform.tfstate"
    use_oidc              = true
  }
}