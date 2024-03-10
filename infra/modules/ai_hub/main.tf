#########################################
# Azure AI Hub
#########################################
resource "azapi_resource" "hub" {
  type      = "Microsoft.MachineLearningServices/workspaces@2023-10-01"
  name      = "aihub-${var.environment_name}"
  location  = var.location
  parent_id = var.resource_group_id
  identity {
    type = "SystemAssigned"
  }
  
  body = jsonencode({
    kind     = "Hub"
    properties = {
      friendlyName = "aihub-${var.environment_name}-${var.location}"
      keyVault = var.key_vault_id
      applicationInsights = var.application_insights_id
      storageAccount = var.storage_account_id
    }
  })

  schema_validation_enabled = false
}
